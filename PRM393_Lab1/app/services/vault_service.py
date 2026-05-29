
import os


def save_markdown(vault_path, filename, content):

    papers_folder = os.path.join(
        vault_path,
        "Papers"
    )

    os.makedirs(papers_folder, exist_ok=True)

    full_path = os.path.join(
        papers_folder,
        filename
    )

    with open(full_path, "w", encoding="utf-8") as f:
        f.write(content)

    return full_path