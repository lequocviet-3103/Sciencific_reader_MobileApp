from fastapi import APIRouter, UploadFile, File, HTTPException
from pydantic import BaseModel

from app.services.extract_service import extract_text_from_pdf
from app.services.groq_service import analyze_paper
from app.services.markdown_service import generate_markdown
from app.services.vault_service import save_markdown

import shutil
import os
import traceback
import uuid

router = APIRouter()

UPLOAD_FOLDER = "uploads"
VAULT_FOLDER = "vault"

os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(VAULT_FOLDER, exist_ok=True)


class MarkdownUpdateRequest(BaseModel):
    file_path: str
    content: str


@router.post("/process-paper")
def process_paper(file: UploadFile = File(...)):

    try:

        # Save PDF
        safe_filename = os.path.basename(file.filename or "") or "upload.pdf"
        short_id = uuid.uuid4().hex[:8]
        name_without_ext = os.path.splitext(safe_filename)[0]
        ext = os.path.splitext(safe_filename)[1]

        unique_filename = f"{name_without_ext}_{short_id}{ext}"
        pdf_path = os.path.join(UPLOAD_FOLDER, unique_filename)

        with open(pdf_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        print("PDF SAVED:", pdf_path)

        # Step 1: Extract text
        text = extract_text_from_pdf(pdf_path)

        print("TEXT EXTRACTED")

        # Step 2: Analyze paper with Groq
        data = analyze_paper(text)

        print("GROQ ANALYZED")

        # Step 3: Convert to markdown
        markdown = generate_markdown(data)

        print("MARKDOWN GENERATED")

        # Step 4: Save markdown
        md_filename = os.path.splitext(unique_filename)[0] + ".md"

        saved_path = save_markdown(
            vault_path=VAULT_FOLDER, filename=md_filename, content=markdown
        )

        print("MARKDOWN SAVED:", saved_path)

        return {
            "message": "success",
            "markdown_file": saved_path,
            "markdown_content": markdown,
        }

    except Exception as e:

        traceback.print_exc()

        raise HTTPException(status_code=500, detail=str(e))


@router.post("/update-markdown")
def update_markdown(request: MarkdownUpdateRequest):
    try:
        # Basic security check to prevent path traversal
        if ".." in request.file_path or not request.file_path.startswith(VAULT_FOLDER):
            raise HTTPException(status_code=400, detail="Invalid file path.")

        # The file_path from the client is already prefixed with 'vault/'
        # so we can use it directly.
        full_path = os.path.abspath(request.file_path)

        if not os.path.exists(os.path.dirname(full_path)):
             raise HTTPException(status_code=404, detail="Directory not found.")

        with open(full_path, "w", encoding="utf-8") as f:
            f.write(request.content)

        return {"message": "success"}
    except HTTPException as e:
        raise e # Re-raise HTTPException
    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))
