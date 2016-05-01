import solr

# create a connection to a solr server
s = solr.SolrConnection('http://localhost:8983/solr/omca-public')

# do a search
response = s.query('objname_txt:canoe')
for hit in response.results:
    print hit['objmusno_s']
