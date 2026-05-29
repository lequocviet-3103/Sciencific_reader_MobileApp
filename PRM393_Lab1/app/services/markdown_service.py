def generate_markdown(data):

    concepts = "\n".join(
        [f"- [[{concept}]]" for concept in data["concepts"]]
    )

    markdown = f"""
# {data['title']}

## Abstract
{data['abstract']}

## Introduction
{data['introduction']}

## Methods
{data['methods']}

## Results
{data['results']}

## Discussion
{data['discussion']}

## Concepts
{concepts}
"""

    return markdown