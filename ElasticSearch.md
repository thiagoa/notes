# ElasticSearch

## References

- [All About Analyzers](https://www.elastic.co/blog/found-text-analysis-part-1)
- [Tokenizers](https://www.elastic.co/guide/en/elasticsearch/reference/5.5/analysis-tokenizers.html)
- [Compound Word Token Filters](https://www.elastic.co/guide/en/elasticsearch/reference/5.6/analysis-compound-word-tokenfilter.html)
- [How to Use Fuzzy Searches in Elasticsearch](https://www.elastic.co/blog/found-fuzzy-search)
- [Dealing with Human Language](https://www.elastic.co/guide/en/elasticsearch/guide/current/languages.html)
- [Finding Associated Words](https://www.elastic.co/guide/en/elasticsearch/guide/current/shingles.html)
- [Identifying Words](https://www.elastic.co/guide/en/elasticsearch/guide/current/identifying-words.html)
- [Kibana](https://www.elastic.co/products/kibana)

## Source

Reference: [Basic Concepts](https://www.tutorialspoint.com/elasticsearch/elasticsearch_basic_concepts.htm)

- Node: a single running instance of ES
- Cluster: a collection of nodes
- Index: a collection of document properties
- Type / Mapping: a collection of documents sharing a set of common fields
- Document: a collection of fields. Belongs to type, resides inside an index, has an UID
- Shards: independent divisions which indexes are made of. Contains all properties of document and can be stored in any node.
- Replicas: Helps in increasing availability of data and resilience to failure. Improves search performance with parallelization.

## Match all: fetching everything from an index

`match_all` returns everything and gives every document a score of 1.0:

```sh
curl -H 'Content-Type: application/json' -X POST -d '{"query": {"match_all": {}}}' http://localhost:9200/sales/sale/_search?pretty=true
```

## Creating an index

```sh
curl -X PUT http://localhost:9200/schools?pretty=true
```

## Deleting an index

```sh
curl -X DELETE http://localhost:9200/sales_development
```

## Listing available indices

```sh
curl 'http://elasticsearch:9200/_cat/indices'
```

The following columns are returned in the output:

```
health status index uuid pri rep docs.count docs.deleted store.size pri.store.size
```

## Refreshing an index

Makes all operations since last refresh available for search:

```sh
curl -X POST 'http://elasticsearch:9200/sales/_refresh'
```

## Checking the index mapping

```sh
curl 'http://localhost:9200/sales/_mapping?pretty=true'
```

## Checking the index definition

```sh
curl -X GET http://localhost:9200/schools_gov?pretty=true
```

## Checking how a term will be analyzed

```sh
curl -H 'Content-Type: application/json' -X POST -d '{"analyzer": "english", "text": "iphone to charger"}' 'http://localhost:9200/sales/_analyze?pretty=true'
curl -H 'Content-Type: application/json' -X POST -d '{"field": "name", "text": "iphone to charger"}' 'http://localhost:9200/sales/_analyze?pretty=true'
```

## Types of queries

Reference: [Most Important Queries](https://www.elastic.co/guide/en/elasticsearch/guide/current/_most_important_queries.html)

## Creating a record with index API

```sh
curl -X POST -H 'Content-Type: application/json' -d '{
   "name":"City School", "description":"ICSE", "street":"West End", "city":"Meerut", 
   "state":"UP", "zip":"250002", "location":[28.9926174, 77.692485], "fees":3500, 
   "tags":["fully computerized"], "rating":"4.5"
}' http://localhost:9200/schools/school/4
```

## Creating records with the bulk API

```sh
curl -X POST -H 'Content-Type: application/x-ndjson' --data-binary @request.json http://localhost:9200/schools/_bulk?pretty=true
```

`--data-binary @request.json` reads a file named `request.json`. Assume the following contents:

```
{ "index":{ "_index":"schools", "_type":"school", "_id":"1" } }
{ "name":"Central School", "description":"CBSE Affiliation", "street":"Nagan", "city":"paprola", "state":"HP", "zip":"176115", "location":[31.8955385, 76.8380405], "fees":2000, "tags":["Senior Secondary", "beautiful campus"], "rating":"3.5" }
{ "index":{ "_index":"schools", "_type":"school", "_id":"2" } }
{ "name":"Saint Paul School", "description":"ICSE Afiliation", "street":"Dawarka", "city":"Delhi", "state":"Delhi", "zip":"110075", "location":[28.5733056, 77.0122136], "fees":5000, "tags":["Good Faculty", "Great Sports"], "rating":"4.5" }
{ "index":{"_index":"schools", "_type":"school", "_id":"3"} }
{ "name":"Crescent School", "description":"State Board Affiliation", "street":"Tonk Road", "city":"Jaipur", "state":"RJ", "zip":"176114","location":[26.8535922, 75.7923988], "fees":2500, "tags":["Well equipped labs"], "rating":"4.5" }
```

## Searching in all indexes

Uses the query string query:

```sh
curl -H 'Content-Type: application/json' -d '{"query": {"query_string": {"query": "Model"}}}' -X GET http://localhost:9200/_all/_search?pretty=true
```

## Some types of queries

- Term level queries: operate on the **exact** terms stored in the inverted index
- Full text queries: analyze the query string before executing. They understand
  how the field being queried is analyzed and apply each field's analyzer to
  the query string before executing.

## Combining queries

Reference: [Combining Queries Together](https://www.elastic.co/guide/en/elasticsearch/guide/current/combining-queries-together.html)

## Full-text queries

### Match query

Is a boolean query.

```sh
curl -H 'Content-Type: application/json' -d '{"query": {"match": {"name": "School Model"}}}' http://localhost:9200/schools_gov/_search?pretty=true | pbcopy
```

It's the same as:

```sh
curl -H 'Content-Type: application/json' -d '{"query": {"match": {"name": {"query": "School Model", "operator": "or"}}}}' http://localhost:9200/schools_gov/_search?pretty=true
```

That is, "School" OR "Model". We can also use "AND" instead of "OR".

Selecting records that match a minimum of 2 clauses instead of just 1:

```sh
curl -H 'Content-Type: application/json' -d '{"query": {"match": {"name": {"query": "School Model One Two", "operator": "or", "minimum_should_match": 2}}}}' http://localhost:9200/schools_gov/_search?pretty=true
```

- For an `OR` query, `minimum_should_match` defaults to 1. Which means at least 1 term should match.
- For an `AND` query, `minimum_should_match` kills the query completely and makes it return nothing.

## Explain

```sh
curl -H 'Content-Type: application/json' -d '{"query": {"match": {"name": {"query": "Model School", "operator": "or"}}}}' http://localhost:9200/schools_gov/_search?pretty=true\&explain=true
```

## Analyzers

Reference: [Found Text Analysis part 1](https://www.elastic.co/blog/found-text-analysis-part-1)

An analyzer is composed of:

- Character filters (ex lowercase text, substitute words)
- Tokenizer (the only required component in an analyzer - emits a list of tokens)
- Token filters (optional, to further alter the tokens)

A token contains a string value and a position number.

## Relevance

In ES, the standard similarity algorithm is TF/ITF:

- Term frequency: how often does a term appear in a field? The more often, the more relevant.
- Inverse term frequency: how often does a field appear in the index? The more often, the less relevant.
- Field-length norm: How long is the field content? The shorter the field, the more relevant.

Randos:

- Queries are returned in descending order of relevance (`_score` field)
- TF/ITF is combined with whatever relevance algorithm for the query at hand
- "Term proximity" in phrase queries or "term similarity" in fuzzy queries.
- In a boolean OR query, the more clauses matching, the higher the `_score`.
- In a boolean query, the `_score` for each clause is combined to deliver a final
  result.

### Disabling term frequencies for analyzed fields

It is possible to disable term frequencies for a field when creating an index,
for when you don't care how often a term a present, but only that it **IS**
present.

Example: `"text" => { "type": "string", "index_options": "doc" }`.
That way, the score will not be calculated nor added to the final score.

TODO: Try out some examples. Put a term in two distinct fields and see how
explain behaves.

### Disabling field-length norm for analyzed fields

`norms` is good for full-text search, but many fields don't need it.

```
{
  "mappings": {
    "doc": {
      "properties": {
        "text": {
          "type": "string",
          "norms": { "enabled": false } 
        }
      }
    }
  }
}
```
