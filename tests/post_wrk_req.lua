counter = 0

wrk.method = "POST"
wrk.headers["Content-Type"] = "application/x-www-form-urlencoded"

request = function()
   path = "/person"
   wrk.body = "last_name=Kupchik&first_name=Vladislav&age=26&login=kvs-" .. counter
   counter = counter + 1
   return wrk.format(nil, path)
end
