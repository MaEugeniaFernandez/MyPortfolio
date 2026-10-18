---
layout: page
title: "Unit 10 - API Security Requirements Specification Task"
---

For this task we were asked to evaluate the security requirements of an API of our choice, and to write a brief specification that reduces the risks of using it to connect a Python program with XML, JSON and SQL.

---

## 1. The API

I chose the **UK Companies House API**. It gives free access to information about UK companies and their directors, and it covers all three formats:

- **JSON**: company and director records come back as JSON.
- **XML**: some company accounts can be downloaded as XML (iXBRL).
- **SQL**: my Python program saves the cleaned data into a SQLite database.

```
Python program ──HTTPS + API key──► Companies House API ──► JSON / XML
       │
       ▼
 SQL database
```

---

## 2. What needs protecting

- **The API key**: it identifies my program, so others must not be able to use it.
- **Personal data**: director names, birth dates and addresses are public, but they are still personal data under UK GDPR.
- **The database**: it holds all the collected data in one place.
- **The service itself**: the API allows only 600 requests every 5 minutes, and programs that keep breaking this limit can be banned (Companies House, no date).

---

## 3. Risks and security requirements

| Risk | What could happen | Requirement (what the program must do) |
|---|---|---|
| **API key leak** | The key is pushed to GitHub and someone else uses it | Keep the key in an environment variable, never in the code. If it leaks, cancel it and create a new one. |
| **Data intercepted** | Someone reads the data while it travels over the network | Always use HTTPS and never turn off certificate checks. |
| **Too many requests** | The program gets `429` errors or is banned | Stay under 600 requests per 5 minutes. Wait and retry when a `429` error comes back. Do not request the same record twice. |
| **Bad JSON** | Missing or unexpected fields crash the program or save wrong data | Check each JSON response has the expected fields and types before using it. |
| **Harmful XML** | A crafted XML file reads local files or uses up all the memory (XXE, "billion laughs") | Parse XML with the `defusedxml` library and reject very large files. |
| **SQL injection** | Text from the API, such as a company name, is run as a SQL command | Always use parameterised queries (`?` placeholders), never build SQL by joining strings. |
| **Bad user input** | A typo or a crafted company number changes the request URL | Check company numbers are exactly 8 letters or digits before sending the request. |
| **Privacy (UK GDPR)** | Too much personal data is kept, for too long, or shared too widely | Store only the fields that are needed, delete old data after a set time, and do not share personal data outside the team. |
| **Out-of-date data** | The register changes every day, so old data gives wrong answers | Save the date each record was downloaded and refresh old records. |

---

## 4. Examples in Python

**Keeping the key secret and handling the rate limit:**

```python
import os
import time
import requests

API_KEY = os.environ["CH_API_KEY"]      # the key is not written in the code
BASE_URL = "https://api.company-information.service.gov.uk"

def get_company(number):
    for attempt in range(5):
        response = requests.get(f"{BASE_URL}/company/{number}",
                                auth=(API_KEY, ""), timeout=30)
        if response.status_code == 429:  # too many requests
            time.sleep(2 ** attempt)     # wait 1, 2, 4, 8, 16 seconds
            continue
        response.raise_for_status()
        return response.json()
    raise RuntimeError("Still rate-limited after 5 attempts")
```

**Reading XML safely:**

```python
from defusedxml.ElementTree import fromstring

accounts = fromstring(xml_content)       # blocks harmful XML tricks
```

**Saving to SQL safely:**

```python
cursor.execute(
    "INSERT INTO company (company_number, company_name) VALUES (?, ?)",
    (data["company_number"], data["company_name"]),
)
```

---

## 5. Limitations and opportunities

- **Limitations:** these rules only protect our side. We still have to trust that the Companies House data is correct. The rate limit makes collecting large amounts of data slow, and many accounts are only available as PDFs, not XML.
- **Opportunities:** Companies House also offers bulk downloads, which avoid the rate limit for large datasets, so these could be used then.

---


## Reference List

Companies House (no date) *Rate limiting*. Available at: [https://developer-specs.company-information.service.gov.uk/guides/rateLimiting](https://developer-specs.company-information.service.gov.uk/guides/rateLimiting) (Accessed: 14 October 2026).

## Bibliography

Information Commissioner's Office (2026) *A guide to the data protection principles*. Available at: [https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/data-protection-principles/a-guide-to-the-data-protection-principles/](https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/data-protection-principles/a-guide-to-the-data-protection-principles/) (Accessed: 14 October 2026).

Kazil, J. and Jarmul, K. (2016) *Data Wrangling with Python*. Sebastopol, CA: O'Reilly Media.

OWASP (2023) *OWASP API Security Top 10 – 2023*. Available at: [https://owasp.org/API-Security/editions/2023/en/0x11-t10/](https://owasp.org/API-Security/editions/2023/en/0x11-t10/) (Accessed: 14 October 2026).

<ul class="actions">
	<li><a href="{{ '/modules/deciphering-big-data/module-contents/unit-10/' | relative_url }}" class="button">Back to Unit 10</a></li>
</ul>
