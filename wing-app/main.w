bring cloud;
bring ex;

let bucket = new cloud.Bucket();
let counter = new cloud.Counter(initial: 1);
let pkCounter = new cloud.Counter(initial: 1) as "db-primary-key";
let queue = new cloud.Queue();
let api = new cloud.Api();

let db = new ex.Table(
  name: "messages",
  primaryKey: "id",
  columns: {
    "data" => ex.ColumnType.STRING,
    "create_date" => ex.ColumnType.STRING
  }
);


api.get("/message", inflight (request: cloud.ApiRequest): cloud.ApiResponse => {
  let result = Json { reult: "success" };
  return cloud.ApiResponse {
    status: 200,
    body: Json.stringify(db.list())
  };
});


api.post("/message", inflight (request: cloud.ApiRequest): cloud.ApiResponse => {
   if let body = request.body {
    let message = Json.stringify(
      Json {data: body, create_date: datetime.utcNow().toIso()});
    queue.push(message);

    let pk = pkCounter.inc(); 
    
    db.insert("{pk}", Json.parse(message));
    return cloud.ApiResponse {
      status: 201,
      body: message
    };
   }
});

queue.setConsumer(inflight (message: str) => {
  let index = counter.inc();
  bucket.put("wing-{index}.txt", "{message}");
  log("file wing-{index}.txt created");
});