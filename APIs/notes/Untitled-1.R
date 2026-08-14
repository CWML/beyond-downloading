
## RESTful APIs in biomedical/public health research

Many health and public data services expose **RESTful** (or “REST-like”) APIs. REST isn’t a single technology; it’s a design style that makes APIs predictable and interoperable.

### The core idea: resources + representations

In REST-style APIs, you interact with **resources** (things) using URLs, and you receive **representations** (often JSON) of those resources.

Examples of “resources” in biomedical/public health contexts: - a publication record - a clinical trial - an adverse event report - a county-level indicator - a dataset row in an open-data portal

### Headers (metadata about the request/response)

Headers often matter in practice: - `Accept: application/json` — ask for JSON - `User-Agent` — identify your tool (polite practice for scraping; sometimes for APIs too) - `Authorization: Bearer <token>` — common token format - API key headers (varies by service)

### Parameters and filtering

Most APIs let you filter/shape results using query parameters, such as: - date ranges: `start_date=...&end_date=...` - geography: `state=09&county=001` - selecting fields: `fields=...` - sorting: `sort=...`

### Data formats: JSON and “tidying”

API responses are often **nested JSON**, meaning you may need to: - “flatten” nested objects into columns - unpack arrays (one-to-many relationships) - cast strings to dates/numbers - handle missing fields robustly

### Provenance: what to record for methods/reproducibility

For every API pull, log: - endpoint URL - parameters (including filters and selected fields) - access date/time (UTC) - API version (if available) - software/package versions used to retrieve the data


####################################################

## Choosing an API dataset (quick criteria)

- What is the **unit of analysis**? (person, county, hospital, trial)
- How often is it updated?
- What are the **terms/limits**?
- What fields are available? Are definitions clear?
- Are there stable identifiers? (FIPS, NPI, trial IDs, DOIs)


####################################################





# Wrapping it all up – From curiosity to pipeline

## 1. Common skeleton

- Identify endpoint + docs
- Auth if needed
- Build query (params/body)
- Send request (GET/POST)
- Handle errors / rate limits
- Parse JSON/XML → table
- Clean, validate, record provenance

## 2. Reproducibility checklist

☐ Save raw response (or hash)

☐ Log URL/params + timestamp + API version

☐ Pin package versions / environment info

☐ Respect robots.txt / rate limits

☐ Secure tokens (env vars or vault)

## 3. Where to go next

- Explore additional endpoints: FDA Device, CMS Open Payments, EPA, WHO, UN, etc.
- Learn asynchronous / parallel request patterns for large pulls (furrr, async in Python).
- Pair APIs with geospatial analysis (sf, tigris, leaflet).
- Automate updates with cron / GitHub Actions.

## 4. Key takeaway

- Different APIs, one mental model: endpoints + params + auth + pagination + parse + provenance. Master the pattern once and you can unlock a universe of public-interest data for transparent, up-to-date, and scalable health research.

- Feel free to drop these enhanced sections into your materials and tweak the wording or examples to match your audience and time constraints.



# Wrapping Up

## 1. Key take-aways

- **Same playbook, different sites**\
  No matter where the data lives, the steps are: find the URL, send a request, get the reply, turn it into a table, and write down what you did.

- **Keep it reproducible**\
  Save the URL (plus any filters), note the date you downloaded, and jot down which R packages you used. That’s enough for someone else (or future-you) to rerun the pull.

- **Respect the ecosystem**\
  Use an official API when one exists, slow down big jobs, and read the “terms of use.” Scraping is the last resort.

- **Automate early**\
  Wrap your code in a function and schedule it—then fresh data is only a click (or a cron job) away.

- **Stay curious**\
  New health data sources pop up all the time. Once you know the basics, trying a new one is mostly copy-paste.

## 2. Suggested next steps

| Level-up | Action |
|---------------------------|---------------------------------------------|
| **Async / parallel pulls** | Try `furrr` or `curl_multi()` for paginated APIs with thousands of calls. |
| **Secrets management** | Store tokens in `.Renviron`, `keyring`, or a cloud vault; never hard-code in scripts. |
| **Robust scraping** | Explore `chromote`, `RSelenium`, or `playwright` for JavaScript-heavy sites. |
| **Geospatial joins** | Pair API outputs with `sf`, `tigris`, or `tidycensus::get_decennial()` boundary data. |
| **Publication-ready docs** | Convert this notebook to PDF, slide decks, or dashboards with Quarto multi-format. |

## 3. Handy links

| Link | Why you’d use it |
|----------------------|--------------------------------------------------|
| **CT Open Data Portal** — <https://data.ct.gov> | State-level health & policy datasets in a Socrata wrapper (supports `$select`, `$where`, etc.). |
| **Census Developer Portal** — <https://www.census.gov/data/developers/data-sets.html> | Official docs, variable lists, and examples for ACS, Decennial, Economic Census, and more. |
| **NCHS Vital Statistics** — <https://www.cdc.gov/nchs/data_access/vitalstatsonline.htm> | Birth/death micro-data, natality, mortality, and compressed mortality files (often FTP + API hybrids). |
| **ClinicalTrials.gov API** — <https://clinicaltrials.gov/api/info/study_fields_list> | Retrieve study fields, statuses, locations; essential for trial landscape or compliance work. |
| **OpenFDA** — <https://open.fda.gov/apis/> | Drug, device, food event surveillance; supports powerful nested queries and pagination. |
| **NCBI E-utilities** — <https://www.ncbi.nlm.nih.gov/books/NBK25500/> | Programmatic PubMed, PMC, GenBank access; cornerstone for reproducible literature searches. |
| **Socrata API docs** — <https://dev.socrata.com/docs/endpoints> | Generic guide for thousands of city/state portals (CDC, HHS, EPA, etc.). |
| **Census main API landing** — <https://api.census.gov/data/> | Direct links to every vintage & survey; great for discovering obscure datasets (e.g., LEHD, CPS). |
| **CDC WONDER API help** — <https://wonder.cdc.gov/wonder/help/wonder-api.html> | Documentation for WONDER’s SQL-like query interface (mortality, natality, underlying cause of death). |
| **OHDSI GitHub** — <https://github.com/OHDSI/> | Open-source tooling (Atlas, Achilles) around the OMOP common data model — valuable for EHR research. |
| **OHDSI Athena vocabularies** — <https://athena.ohdsi.org/search-terms/start> | Download standard vocabularies (SNOMED, RxNorm, LOINC) for mapping local codes to OMOP. |
| **Example CDC dataset** — <https://dev.socrata.com/foundry/data.cdc.gov/wnjn-mave> | A live schema page showing field types, sample API calls, and metadata. |

## 4. Thank you & stay connected!

Please email me at maximilian.wegener\@yale.edu if you have any questions. 





###########################################################################################



## API demonstrations (one per source)

### NHANES R package — survey data access

**Use cases** - quick access to NHANES data - access the most recent survey cycles without manual file downloads - merge datasets across modules using participant ID (`SEQN`)

**NHANES organizes data into separate modules (demographics, labs, examinations, questionnaires, etc.), which are linked by participant ID (`SEQN`).**

#### Query demographic and body measurement datasets

```{r}
# R demo skeleton (NHANES via nhanesA package)
# packages used: NHANES, nhanesA, tidyverse

# Example: get demographic data for 2021-2023 cycle (most recent) denoted by "L"
nhanes_demo <- nhanes('DEMO_L')
#head(nhanes_demo)

# Example: get physical measurement data for 2021-2023 cycle (most recent) denoted by "L"
nhanes_bmx <- nhanes('BMX_L')
#head(nhanes_bmx)
```

The syntax changes across APIs, but the overall research workflow is remarkably similar.

#### Then you can merge/join datasets using the participant ID (`SEQN`) to create an analysis-ready table.

It is important to note that using a data dictionary is crucial to understand the variables and their coding. For example, `RIAGENDR` is coded as 1 for male and 2 for female.

```{r}
nhanes_data <- nhanes_demo %>%
  left_join(nhanes_bmx, by = "SEQN") %>%
  select(SEQN, RIDAGEYR, RIAGENDR, BMXBMI)

head(nhanes_data)
```

### PubMed (NCBI E-utilities) — literature metadata

**Use cases**

- reproducible literature searches
- retrieve PMIDs + basic citation metadata
- build screening datasets

**NCBI requests should follow usage guidelines and include reasonable request pacing for large retrieval jobs.**

```{r }
# R demo skeleton (E-utilities via httr2)

# packages used: httr2, jsonlite, dplyr, tibble

base <- "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi"
query <- list(
  db = "pubmed",
  term = "asthma[MeSH Terms] AND 2023[pdat]",
  retmode = "json",
  retmax = 20
)

resp <- request(base) |> req_url_query(!!!query) |> req_perform()
txt <- resp |> resp_body_string()
dat <- fromJSON(txt)

pmids <- dat$esearchresult$idlist
tibble(pmid = pmids)
```

### ClinicalTrials.gov — trial registry metadata

**Use cases**

- find trials by condition/intervention/location
- compare outcomes reporting patterns
- sponsor/phase landscape scans

```{r}
# R demo skeleton (ClinicalTrials.gov via httr)
#  
# Packages used: httr, jsonlite, dplyr, tibble

# ---- endpoint & parameters ----
url <- "https://clinicaltrials.gov/api/v2/studies"

params <- list(
  `query.term` = "diabetes",
  pageSize      = 10
)

# ---- request ----
resp <- GET(url, query = params, timeout(30))

# error if HTTP status is not 200
stop_for_status(resp)

# ---- parse JSON ----
data_txt <- content(resp, as = "text", encoding = "UTF-8")
data     <- fromJSON(data_txt, flatten = TRUE)

# ---- extract the studies array ----
studies <- data$studies            # flatten nested JSON into a data frame

# ---- inspect / use ----
studies_tbl <- as_tibble(studies)
#print(studies_tbl, n = 10, width = Inf)
str(studies_tbl)
```

### OpenFDA — adverse events / labeling

**Use cases**

- pharmacovigilance exploration
- counts over time, stratified by drug/product fields
- teaching filtering + pagination

```{r}
# R demo skeleton (OpenFDA via httr)

# packages used: httr, jsonlite, dplyr, tibble

# ---- endpoint & parameters ----
base   <- "https://api.fda.gov/drug/event.json"
params <- list(
  search = 'patient.drug.medicinalproduct:"metformin"',
  limit  = 5
)

# ---- request ----
resp <- GET(base, query = params, timeout(30))
stop_for_status(resp)                       # error if HTTP status ≥ 400

# ---- parse JSON ----
txt <- content(resp, as = "text", encoding = "UTF-8")
j   <- fromJSON(txt, flatten = TRUE)

# ---- extract the results array ----
fda_df <- j$results %>%            # NULL if no hits
        as_tibble()

#print(fda_df, n = 5, width = Inf)  # show the 5 rows we requested
```

### CDC open data (Socrata-style)

Many government open-data portals use Socrata APIs, which support SQL-like query parameters such as `$select`, `$where`, and `$limit`.

https://dev.socrata.com/docs/endpoints

**Use cases**

- quick access to many public datasets
- teach “select/where/limit” query patterns

**Run this chunk to find the endpoint for a dataset of interest (e.g., COVID-19 hospitalization surveillance)**

Search other datasets by changing the `q` parameter and/or domain filter. Note that some CDC datasets are on data.cdc.gov, but others may be on different domains (e.g., wonder.cdc.gov). You can also explore the Socrata API documentation for more complex queries and dataset discovery.

```{r}
# R demo skeleton: Socrata dataset discovery (you will replace the query with your own topic of interest)

# packages used: httr2, jsonlite, dplyr, tibble

catalog <- request("https://api.us.socrata.com/api/catalog/v1") |>
  req_url_query(q = "COVID-19 hospitalization", domains = "data.cdc.gov") |>
  req_perform() |>
  resp_body_json()

catalog$results[[1]]$resource$id  
```

**Run this chunk with the dataset-specific endpoint to get data (replace the XXXX-XXXX with the one you found in the previous step)**

```{r}
# R demo skeleton: Socrata-style endpoint (you will replace with a specific dataset)

# packages used: httr2, jsonlite, dplyr, tibble

# Many Socrata datasets support SODA queries via $select, $where, $limit.
# Replace with a concrete dataset endpoint you choose for class:
# Example form: https://data.cdc.gov/resource/XXXX-XXXX.json

endpoint <- "https://data.cdc.gov/resource/aemt-mg7g.json"

resp <- request(endpoint) |>
  req_url_query(`$limit` = 20) |>
  req_perform()

resp_dat <- fromJSON(resp_body_string(resp), flatten = TRUE)
as_tibble(resp_dat)
```

# Part 3 — Census API (token + joins)

## Why the Census/ACS matters in health research

Adds **population context** for:

- Denominators to turn counts into rates
- Social determinants proxies (income, education, housing, internet)
- Fine-grained geographies (tract, ZIP, county, ZCTA, PUMA, etc.)
- Annual or 5-year series for trend analysis

Common outputs:

- tract/county/state estimates
- ACS variables (multi-year)

## Getting a Census API token

1.  Request one free key: https://api.census.gov/data/key_signup.html
2.  Store it safely (e.g. in \~/.Renviron as CENSUS_API_KEY=ABC…).
3.  Load it in R:

## Store your Census key (R example)

```{r}
# Set your key in .Renviron (permanenet, editsable, one-time setup)
# Should look like this: CENSUS_API_KEY=YOUR_KEY_HERE

file.edit("~/.Renviron")
```

## Load your Census API key from environment variables (R example)

```{r}
# You only need to run this once per R session to load the key into your environment. It will be available for all tidycensus functions after this.

# packages used: tidycensus

#Sys.getenv("CENSUS_API_KEY")
census_api_key(Sys.getenv("CENSUS_API_KEY"), install = TRUE, overwrite = TRUE)
```

## Test your key and make a simple request (R example)

```{r}
# This is a simple test to see if your key is working and to get a basic population estimate for all states in 2023. You should see a table with state names, population estimates, and margins of error.

# packages used: tidycensus

get_acs(geography = "state", variables = "B01001_001", year = 2023)
```

## Census API: geographies + joins

### Guide to US Census Bureau Data Tables (ACS)

The American Community Survey (ACS) tracks over 1,400 demographic and economic metrics. Instead of searching blindly, you can decipher any Census table code instantly using its alphanumeric structure.

#### 1. Anatomy of a Census Variable Code

Take the code **`B01001_001`**: \* **`B`** (or **`C`**): The Table Type (*Base* or *Collapsed*). \* **`01`**: The Broad Subject Code (*Age & Sex*). \* **`001`** (before the underscore): The unique table sequence sequence number. \* **`_001`** (after the underscore): The specific **line number** (row) inside that table. \* *Tip: Line `_001` is almost always the "Total" count for that whole table.*

#### 2. Cheat Sheet: Table Subject Prefixes

The first two digits after the leading letter tell you exactly what topic the table covers:

| Prefix | Subject Category | Example Metrics Included |
|:-----------------------|:-----------------------|:-----------------------|
| **`01` to `07`** | **Core Demographics** | Age, Sex, Race, Ancestry, and Place of Birth |
| **`08`** | **Commuting & Transit** | Remote work, public transit use, and travel times to work |
| **`11` to `13`** | **Households & Family** | Marital status, family size, and fertility rates |
| **`15` to `16`** | **Education & Language** | High school/college graduation rates, languages spoken at home |
| **`17` to `23`** | **Economics & Finance** | Median Household Income, poverty status, and employment data |
| **`24`** | **Occupations** | Employment fields (Tech, Manufacturing, Service industry splits) |
| **`25`** | **Housing & Living** | Rent vs. Own, home values, monthly utility costs, vehicle counts |

**Helpful website to search tables** https://censusreporter.org

#### 3. High-Engagement Tables for Student Projects

When querying datasets using `get_acs()`, these tables are the most popular for economic, sociological, and geographical data analysis:

- **`B19013`** — Median Household Income
- **`B17001`** — Poverty Status by Sex and Age
- **`B15003`** — Educational Attainment (Population 25 years and older)
- **`B25077`** — Median Value of Owner-Occupied Housing Units
- **`B28002`** — Presence and Type of Household Internet Access (The "Digital Divide")
- **`B25044`** — Vehicles Available per Household

#### 4. `B` Tables vs. `C` Tables (Base vs. Collapsed)

- **`B` (Base Tables):** Provide micro-detailed row breakdowns (e.g., tracking poverty across 20+ micro-age brackets).
- **`C` (Collapsed Tables):** Take the exact same data but compress it into fewer, broader rows (e.g., grouping that same poverty data into just 3 wide age buckets).
  - *If a `B` table dataset feels overwhelming, change the first letter to a `C` for a cleaner overview!*

```{r}
# This example shows how to get population estimates by county in Connecticut, calculate the percentage of the state population for each county, and then build a nice table to display the results. You can adapt this pattern to other geographies, variables, and states as needed.

# packages used: tidycensus, dplyr, flextable, scales

# Load your Census API key (if you haven’t already)
census_api_key(Sys.getenv("CENSUS_API_KEY"))

# ── 1. Population by County (Connecticut) ────────────────────────────────────

county_pop <- get_acs(
  geography = "county",
  variables = "B01001_001",  # we use Variables to calucalte the percentage of the state population for each county; this is the total population variable in the ACS
  state = "CT",
  year = 2023,
  survey = "acs5"
) %>%
  mutate(
    NAME = gsub(" County, Connecticut", "", NAME),
    pct_of_state = (estimate / sum(estimate)) * 100
  )

county_pop
```

## Now we can build a nice table to display the population estimates by county, along with the margin of error and the percentage of the state population.

```{r}
build_county_pop_table <- function() {
  county_pop %>%
    arrange(desc(estimate)) %>%
    select(
      County = NAME,
      Population = estimate,
      #MOE = moe,
      `% of State` = pct_of_state
    ) %>%
    mutate(
      Population = comma(Population),
      #MOE = comma(MOE),
      `% of State` = paste0(round(`% of State`, 1), "%")
    ) %>%
    flextable() %>%
    set_header_labels(
      County = "County",
      Population = "Population",
      #MOE = "Margin of Error",
      `% of State` = "% of State"
    ) %>%
    theme_vanilla() %>%
    bold(part = "header") %>%
    bg(part = "header", bg = "white") %>%
    color(part = "header", color = "black") %>%
    bg(i = seq(2, nrow(county_pop), 2), bg = "#F2F2F2") %>%
    align(j = c("Population", "% of State"), align = "right", part = "all") %>% #removed "MOE" since its all blanks
    set_table_properties(width = 1, layout = "autofit") %>%
    add_footer_lines("Source: U.S. Census Bureau, ACS 5-Year Estimates 2023. Table B01001.")
}

build_county_pop_table()
```

## Now you can call the `build_county_pop_table()` function to display the formatted table of population estimates by county in Connecticut.

```{r}
# Call this to display the table:
build_county_pop_table()
```