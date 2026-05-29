import json
import os
import re

from groq import Groq
from dotenv import load_dotenv

load_dotenv()


def clean_json(text):
    """
    Remove markdown json fences if exists
    """

    text = text.strip()

    text = re.sub(r"^```json", "", text)
    text = re.sub(r"^```", "", text)
    text = re.sub(r"```$", "", text)

    return text.strip()


def analyze_paper(text):

    prompt = f"""
    You are a scientific paper analyzer.

    Extract the paper into IMRAD structure.

    Return ONLY valid JSON.

    {{
      "title": "",
      "abstract": "",
      "introduction": "",
      "methods": "",
      "results": "",
      "discussion": "",
      "concepts": []
    }}

    Scientific Paper:
    {text[:12000]}
    """

    api_key = os.getenv("GROQ_API_KEY")

    if not api_key:
        raise Exception("GROQ_API_KEY is missing. Set the raw Groq key in your .env file.")

    if api_key.lower().startswith("bearer "):
        api_key = api_key.split(" ", 1)[1].strip()

    client = Groq(api_key=api_key)

    completion = client.chat.completions.create(
        model="llama-3.1-8b-instant",
        messages=[
            {
                "role": "user",
                "content": prompt
            }
        ],
        temperature=0.2
    )

    result = completion.choices[0].message.content

    print("RAW RESULT:")
    print(result)

    cleaned = clean_json(result)

    try:
        data = json.loads(cleaned)
        return data

    except Exception as e:

        print("JSON ERROR:", e)

        return {
            "title": "Unknown",
            "abstract": "",
            "introduction": cleaned,
            "methods": "",
            "results": "",
            "discussion": "",
            "concepts": []
        }