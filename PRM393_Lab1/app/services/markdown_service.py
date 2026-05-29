def generate_markdown(data):
    concepts = "\n".join(
        [f"- [[{concept}]]" for concept in data.get("concepts", [])]
    )

    markdown = f"""
# {data.get('title', 'Unknown')}

## Abstract
{data.get('abstract', '')}

## Introduction
{data.get('introduction', '')}

## Methods
{data.get('methods', '')}

## Results
{data.get('results', '')}

## Discussion
{data.get('discussion', '')}

## Concepts
{concepts}
"""

    return markdown
