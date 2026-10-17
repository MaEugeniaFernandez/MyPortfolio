import json
import requests
from bs4 import BeautifulSoup

KEYWORD = "Data Scientist"
URL = "https://realpython.github.io/fake-jobs/"

response = requests.get(URL)    # downloads web page
response.raise_for_status()     # stops the script if the download failed

soup = BeautifulSoup(response.text, "html.parser") # BeautifulSoup reads the HTML

job_cards = soup.find_all("div", class_="card-content") # finds every job advert on the page, considering each advert sits inside <div class="card-content">
print("Job adverts found on the page:", len(job_cards))

results = [] # keeps only job adverts containing "Data Scientist" in the title

for card in job_cards:      # iterates each of the job adverts of the web page
    title = card.find("h2", class_="title").get_text(strip=True)
    
    if KEYWORD.lower() in title.lower():  # .lower() makes it ignore capital letters, so "Data scientist" also matches "Data Scientist"

        company = card.find("h3", class_="company").get_text(strip=True) # pulls out all of the details of each job advert
        location = card.find("p", class_="location").get_text(strip=True)
        date_posted = card.find("time").get_text(strip=True)
        link = card.find_all("a")[-1]["href"]      # the -1 is the "Apply" button link

        detail_page = requests.get(link) # opens each advert's own page to also collect the description
        detail_soup = BeautifulSoup(detail_page.text, "html.parser")
        description = detail_soup.find("div", class_="content").p.get_text(strip=True)

        results.append({            # the results for each job advert and its description are saved as a dictionary
            "keyword": KEYWORD,
            "title": title,
            "company": company,
            "location": location,
            "date_posted": date_posted,
            "url": link,
            "description": description,
        })

print("Adverts matching '" + KEYWORD + "':", len(results)) # prints how many job adverts were found containing the keyword


with open("data_scientist_jobs.json", "w", encoding="utf-8") as file: # saves everything into a JSON file
    json.dump(results, file, indent=4, ensure_ascii=False)

print("Results saved to data_scientist_jobs.json")
