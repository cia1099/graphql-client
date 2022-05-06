const { ApolloServer } = require('apollo-server-express');
const { makeExecutableSchema } = require('@graphql-tools/schema');
const { ApolloServerPluginDrainHttpServer, ApolloServerPluginLandingPageGraphQLPlayground } 
= require('apollo-server-core');
const express = require('express');
const http = require('http');
const expressPlayground = require('graphql-playground-middleware-express')
  .default;

const { WebSocketServer } = require('ws');
const { useServer } = require('graphql-ws/lib/use/ws');

const port = process.env.PORT || 4000;

var _ = require("lodash");
const {PubSub} = require("graphql-subscriptions");
const pubsub = new PubSub();

//dummy data
var usersData = [
     {id: '1', name: 'Bond', age: 36, profession: 'Programmer'},
     {id: '13', name: 'Anna', age: 26, profession: 'Baker'},
     {id: '211', name: 'Bella', age: 16, profession: 'Mechanic'},
     {id: '19', name: 'Gina', age: 26, profession: 'Painter'},
     {id: '150', name: 'Georgina', age: 36, profession: 'Teacher'}
];

var hobbiesData = [
    {id: '1', title: 'Programming', description: 'Using computers to make the world a better place', userId: '150'},
    {id: '2', title: 'Rowing', description: 'Sweat and feel better before eating donouts', userId: '211'},
    {id: '3', title: 'Swimming', description: 'Get in the water and learn to become the water', userId: '211'},
    {id: '4', title: 'Fencing', description: 'A hobby for fency people', userId: '13'},
    {id: '5', title: 'Hiking', description: 'Wear hiking boots and explore the world', userId: '150'},
];

var postsData = [
    {id: '1', comment: 'Building a Mind', userId: '1'},
    {id: '2', comment: 'GraphQL is Amazing', userId: '1'},
    {id: '3', comment: 'How to Change the World', userId: '19'},
    {id: '4', comment: 'How to Change the World', userId: '211'},
    {id: '5', comment: 'How to Change the World', userId: '1'}
];

const schema =`
    type UserType{
        id: ID
        name: String
        age: Int
        profession: String
    }
    type RootQuery{
        user(id:ID!): UserType
        users: [UserType]
    }
    type Mutation{
        createUser(name:String!, age:Int!, profession:String!): UserType
    }
    type Subscription{
        addUser: UserType
    }

    schema{
        query: RootQuery
        mutation: Mutation
        subscription: Subscription
    }
`;

const resolvers = {
    RootQuery: {
        user(parent, args, context){
            return _.find(usersData, {id: args.id}); 
        },
        // users(){
        //     return usersData;
        // },
        users:{
            resolve: ()=> usersData
        }
    },
    Mutation: {
        createUser(parent, args, context){
            let obj = {
                name: args.name,
                age: args.age,
                profession: args.profession,
                id: Math.floor(Math.random()*100+1)
            };
            usersData.push(obj);
            pubsub.publish("new_user", {addUser: obj});
            return obj;
        }
    },
    Subscription: {
        addUser: {
            subscribe: ()=> pubsub.asyncIterator(["new_user"]),
            //ref. https://javascript.tutorialink.com/subscription-not-connecting-using-apolloserver/
            resolve: (payload) =>payload         
        },
    }
};

const executableSchema = makeExecutableSchema({
    typeDefs: schema,
    resolvers: resolvers,
});

const app = express();
const httpServer = http.createServer(app);
const wsServer = new WebSocketServer({
    server: httpServer,
    path: '/graphql',
});
const serverCleanup = useServer({ executableSchema }, wsServer);

const server = new ApolloServer({
    schema: executableSchema,
    plugins: [
        // ApolloServerPluginLandingPageGraphQLPlayground({ httpServer }),
        ApolloServerPluginDrainHttpServer({ httpServer }),
        // Proper shutdown for the WebSocket server.
        {
            async serverWillStart() {
                return {
                    async drainServer() {
                        await serverCleanup.dispose();
                    },
                };
            },
        },
    ],
    
});


server.start().then(()=> {
    server.applyMiddleware({ 
        app,
        //path:'/graphql' 
    });
    app.get('/playground', expressPlayground({ endpoint: `${server.graphqlPath}` }));
});
new Promise(resolve => httpServer.listen({ port: port }, resolve)).then(()=>{
    console.log(`🚀 Server ready at http://localhost:${port}${server.graphqlPath}`);
    console.log(
        `🚀 Subscription endpoint ready at ws://localhost:${port}${server.graphqlPath}`
    );
});