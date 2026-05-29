from fastapi import APIRouter, UploadFile, File, HTTPException

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


@router.post("/process-paper")
async def process_paper(file: UploadFile = File(...)):

    try:

        # Save PDF
        safe_filename = os.path.basename(file.filename or "") or "upload.pdf"
        unique_filename = f"{uuid.uuid4().hex}_{safe_filename}"
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
        md_filename = os.path.splitext(safe_filename)[0] + ".md"

        saved_path = save_markdown(
            vault_path=VAULT_FOLDER, filename=md_filename, content=markdown
        )

        print("MARKDOWN SAVED:", saved_path)

        return {"message": "success", "markdown_file": saved_path}

    except Exception as e:

        traceback.print_exc()

        raise HTTPException(status_code=500, detail=str(e))
