SELECT
  id                                                                 AS id,
  string_agg(dimension || ' ' || value || ' ' || regexp_replace(measurementunit, '^.*\)''(.*)''$', '\1'), '␥') AS dimensions_ss
FROM (SELECT
        co.id,
        dimension,
        value,
        measurementunit,
        rank() OVER (ORDER BY h.pos ASC, d.measurementunit DESC) rnk
      FROM hierarchy h, dimensionsubgroup d, measuredpartgroup p, hierarchy h2, collectionobjects_common co
      WHERE d.id = h.id
            AND p.id = h.parentid
            AND p.id = h2.id
            AND co.id = h2.parentid
     ) x
GROUP BY id
;
