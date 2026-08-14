library(httr2)
#1
geo_req <- request("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi") |> 
  req_url_query(
    db = "gds",
    term = "asthma[Title] AND gse[Filter]",
    retmode = "json",
    retmax = 5
  )

geo_resp <- req_perform(geo_req)
geo_data <- resp_body_json(geo_resp)
geo_ids  <- geo_data$esearchresult$idlist

geo_ids

#2
pdb_req <- request("https://data.rcsb.org/rest/v1/core/entry/4HHB")

pdb_resp <- req_perform(pdb_req)
pdb_data <- resp_body_json(pdb_resp)

## Extract key structural details
title      <- pdb_data$struct$title
resolution <- pdb_data$rcsb_entry_info$resolution_combined[[1]]

title
resolution

#3
umls_req <- request("https://uts-ws.nlm.nih.gov/rest/search/current") |> 
  req_url_query(
    string = "asthma",
    apiKey = "YOUR_UMLS_API_KEY", # Requires free NLM UMLS account key
    pageSize = 5
  )

umls_resp <- req_perform(umls_req)
umls_data <- resp_body_json(umls_resp)
results   <- umls_data$result$results

