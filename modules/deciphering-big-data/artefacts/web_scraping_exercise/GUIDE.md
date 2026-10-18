---
layout: page
title: "Unit 3 - Web Scraping Exercise"
---

For this exercise we were asked to scrape a website of our choosing for the keyword *"Data Scientist"* and save the results as a JSON file, using the Python modules `requests` and `beautifulsoup4`.

---

I decided to search for job postings for *"Data Scientist"*, so I tested several real job sites (LinkedIn and Indeed) but these did not work because they deliverately block web scraping requests. Therefore, I decided to use **<https://realpython.github.io/fake-jobs/>** instead, which is a job board created specifically
for people learning web scraping, and it is in plain HTML and allows for web scraping.

---

## The web scraping script

I first imported the packages I would use for this exercise:

```python
import json
import requests
from bs4 import BeautifulSoup

KEYWORD = "Data Scientist"
URL = "https://realpython.github.io/fake-jobs/"
```

Then, I downloaded the page with `requests.get()`, and told the script to stop running if the download failed with `raise_for_status()`:

```python
response = requests.get(URL)
response.raise_for_status()
```

Then, I handed the HTML to BeautifulSoup, who will read it and turn it into something more searchable.

```python
soup = BeautifulSoup(response.text, "html.parser")
```

Afterwards, I told the script to find every job advert in the web page. When looking at the website's HTML I could see that every job sits inside a chunk that starts with `<div class="card-content">`, so here I am asking the script to bring every one of those chunks.

```python
job_cards = soup.find_all("div", class_="card-content")
```

The script found 100 chunks that started with `<div class="card-content">` (one per job advert).

With the 100 job adverts found, I then asked the script to keep only the ones matching the keyword "Data Scientist" using a `for` that will run through all 100 job adverts until it finds the ones containing the keyword. `.get_text()` throws away the HTML tags and leaves the plain words, and `strip=True` trims off stray spaces.

```python
for card in job_cards:
    title = card.find("h2", class_="title").get_text(strip=True)

    if KEYWORD.lower() in title.lower():
        ...
```

`if KEYWORD.lower() in title.lower():` is the actual keyword search. `.lower()` converts both to lower-case first, so "Data scientist" on the website still matches "Data Scientist". Otherwise, the script would find nothing.

For each match found, the same technique pulls out the company, location, date, and the link so we have a complete record of the job adverts found:

```python
company     = card.find("h3", class_="company").get_text(strip=True)
location    = card.find("p", class_="location").get_text(strip=True)
date_posted = card.find("time").get_text(strip=True)
link        = card.find_all("a")[-1]["href"]
```

`find_all("a")[-1]` means "all the links in this advert, then take the last one", and `[-1]` is Python's way of saying *the last item*. That last link is the Apply button.

Then, the script visits each advert's own page to also grab the description using the same download-and-read pattern again, just now one level deeper:

```python
detail_page = requests.get(link)
detail_soup = BeautifulSoup(detail_page.text, "html.parser")
description = detail_soup.find("div", class_="content").p.get_text(strip=True)
```

Finally, each job is stored as a labelled record and added to the `results` list, which is a dictionary:

```python
results.append({
    "title": title,
    "company": company,
    ...
})
```

Lastly, the results were saved as a JSON file, as requested.

```python
with open("data_scientist_jobs.json", "w", encoding="utf-8") as file:
    json.dump(results, file, indent=4, ensure_ascii=False)
```

---

## What I see in the terminal when running the script

```
Job adverts found on the page: 100
Adverts matching 'Data Scientist': 1
Results saved to data_scientist_jobs.json
```

---

## What the JSON file looks like

```json
[
    {
        "keyword": "Data Scientist",
        "title": "Data scientist",
        "company": "Thomas Group",
        "location": "Port Robertfurt, AA",
        "date_posted": "2021-04-08",
        "url": "https://realpython.github.io/fake-jobs/jobs/data-scientist-26.html",
        "description": "Skin industry nothing rather represent two..."
    }
]
```

---

### Files

- [scrape_data_scientist.py](https://github.com/MaEugeniaFernandez/MyPortfolio/blob/main/modules/deciphering-big-data/artefacts/web_scraping_exercise/scrape_data_scientist.py) – web scraping script
- [data_scientist_jobs.json](https://github.com/MaEugeniaFernandez/MyPortfolio/blob/main/modules/deciphering-big-data/artefacts/web_scraping_exercise/data_scientist_jobs.json) – scraped results

<ul class="actions">
	<li><a href="{{ '/modules/deciphering-big-data/module-contents/unit-3/' | relative_url }}" class="button">Back to Unit 3</a></li>
</ul>
