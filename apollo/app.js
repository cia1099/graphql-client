const express = require("express");
const graphqlHTTP = require("express-graphql");
const cors = require("cors");
// const mongo  ose = require("mongoose");
// const { initializeApp, applicationDefault, cert } = require('firebase-admin/app');
const expressPlayground = require('graphql-playground-middleware-express')
  .default

const schema = require("./schema/schema");


const port = process.env.PORT || 4000;


/*
connect using driver
mongodb+srv://Lin:test123@graphql-course.yefqq.mongodb.net/myFirstDatabase?retryWrites=true&w=majority
 */
// mongoose.connect("mongodb+srv://Lin:test123@graphql-course.yefqq.mongodb.net/myFirstDatabase?retryWrites=true&w=majority",
// {useNewUrlParser: true});
// mongoose.connection.once("open", ()=>{
//     console.log("Yes, we are connected!");
// });
// const serviceAccount = require('./config/flutter-web-128a1-firebase-adminsdk.json');
// initializeApp({
//   credential: cert(serviceAccount)
// });

const app = express();
app.use(cors({
  origin: "*"
}));
app.use("/graphql", graphqlHTTP.graphqlHTTP({
    graphiql: true,
    schema: schema,
}));
//ref. https://blog.logrocket.com/complete-guide-to-graphql-playground/
app.get('/playground', expressPlayground({ endpoint: '/graphql' }));

app.listen(port, ()=>{
    console.log(`Listening for requests on my awesome port ${port}.`);
})