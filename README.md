---
title: NHL API Landing
output: 
  html_document:
    css: styling.css
    toc: true
    toc_float: true
layout: page
---

# NHL Stats API (WIP)

All endpoints described in this section are relative to the following base URL:
`https://api.nhle.com/stats/rest/`

## Common Parameters

- `lang`: Language. Use `en` unless otherwise necessary

## Common Query Parameters

### 


## Players

**Endpoint**: `/{lang}/players`

**Query**
```sh
curl -X GET "https://api.nhle.com/stats/rest/en/players"

curl -X GET "https://api.nhle.com/stats/rest/en/players?cayenneExp=sweaterNumber = 99"
```
