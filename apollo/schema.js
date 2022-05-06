const { type } = require("express/lib/response");
const grapql = require("graphql");
const {
    GraphQLObjectType,
    GraphQLID,
    GraphQLString,
    GraphQLInt,
    GraphQLSchema,
    GraphQLList,
    GraphQLNonNull,
    GraphQLScalarType,
} = grapql;
var _ = require("lodash");
const User = require("../model/User");
const Hobby = require("../model/Hobby");
const Post = require("../model/Post");
const { Timestamp } = require('firebase-admin/firestore');

const saveDocument = function (collectionName, obj) {
    //ref. https://stackoverflow.com/questions/41454050/firebase-database-schema
    db.collection(collectionName)
      .add(obj)
      .then((docRef) => {
        console.log("Document written with ID: ", docRef.id);
      })
      .catch((error) => {
        console.error("Error adding document: ", error);
      });
  };


//Create types
const UserType = new GraphQLObjectType({
    name: "User",
    description: "Documentation for user...",
    fields: () =>({
        id: {type: GraphQLID},
        name: {type: GraphQLString},
        age: {type: GraphQLInt},
        profession: {type: GraphQLString},
        posts: {
            type: new GraphQLList(PostType),
            resolve(parent, args){
                // return _.filter(postsData, {userId: parent.id});
                return Post.find({userId: parent.id});
            }
        },
        hobbies: {
            type: new GraphQLList(HobbyType),
            resolve(parent, args){
                // return _.filter(hobbiesData, {userId: args.id});
                /* 
                Watching chapter "3-15 Posts Query", because we query user by id,
                the args.id will be same as this parent. But in this
                situation, here used parent that should make savvy and safety.
                */
                return Hobby.find({userId: parent.id});
            }
        },
    })
});

const HobbyType = new GraphQLObjectType({
    name: "Hobby",
    description: "Hobby description",
    fields: () =>({
        // id: {type: GraphQLID},
        title: {type: GraphQLString},
        description: {type: GraphQLString},
        user: {
            type: UserType,
            resolve(parent, args){
                // return _.find(usersData, {id: parent.userId});
                return User.findById(parent.userId);
            }
        }
    })
});

const DateScalar = new GraphQLScalarType({
    //ref. https://stackoverflow.com/questions/49693928/date-and-json-in-type-definition-for-graphql
    name: "Date",
    description: "Date custom scalar type",
    parseValue(timestamp) {
        return new Date(timestamp.toDate());
    },
    serialize(timestamp) {
        return new Date(timestamp.toDate()).toISOString();
    },
    // parseLiteral(ast) {
    // if (ast.kind === Kind.INT) {
    //     return new Date(parseInt(ast.value, 10)); // Convert hard-coded AST string to integer and then to Date
    // }
    // return null; // Invalid hard-coded value (not an integer)
    // },
});

const PostType = new GraphQLObjectType({
    name: "Post",
    description: "Post description",
    fields: () =>({
        // id: {type: GraphQLID},
        comment: {type: GraphQLString},
        time: {type: DateScalar},
        user: {
            type: UserType,
            resolve(parent, args){
                // return _.find(usersData, {id: parent.userId});
                return User.findById(parent.userId);
            }
        }
    })
});

//RootQuery
const RootQuery = new GraphQLObjectType({
    name: "RootQueryType",
    description: "Description",
    fields: {
        user:{
            type: UserType,
            args: {id: {type: GraphQLID}},
            resolve(parent, args){
                //we resolve with data
                //get and return data from a database
                // return _.find(usersData, {id: args.id});
                return User.findById(args.id);
            }
        },
        hobby:{
            type:HobbyType,
            args: {id:{type:GraphQLID}},
            resolve(parent, args){
                //return data for our hobby
                // return _.find(hobbiesData, {id: args.id});
                return Hobby.findById(args.id);
            }
        },
        post:{
            type:PostType,
            args: {id:{type:GraphQLID}},
            resolve(parent, args){
                //return data for our post
                // return _.find(postsData, {id: args.id});
                return Post.findById(args.id);
            }
        },
        users: {
            type: new GraphQLList(UserType),
            resolve(parent, args){
                // return User.find({});
                return User.getAll();
            }
        },
    //     /** Error used */
    //     userId: {
    //         type: new GraphQLList(GraphQLString),
    //         resolve(parent,args){
    //             var ids = [];
    //             User.find({}).forEach(element => {
    //                 console.log(element.name);
    //                 ids.push(element.name);
    //             });
    //             console.log(ids);
    //             return ids;
    //         }
    //     },
    //     // hobbies: {
    //     //     type: new GraphQLList(HobbyType),
    //     //     // args: {id: {type: GraphQLID}},
    //     //     resolve(parent, args) {
    //     //        //console.log(args.id)
    //     //        console.log("Hello World Hobbies!" + parent.userId);          
    //     //        //  return Hobby.find({id: args.userId});
    //     //     //    return Hobby.find({id: args.userId});        
    //     //     }
    //     // },
    //     posts: {
    //         type: new GraphQLList(PostType),
    //         resolve(parent, args){
    //           return Post.find({});
    //     }
    //    }
    }
});

//Mutations
const Mutation = new GraphQLObjectType({
    name: "Mutation",
    fields:{
        createUser: {
            type: UserType,
            args: {
                name: {type: GraphQLString},
                age: {type: GraphQLInt},
                profession: {type: GraphQLString}
            },
            resolve(parent, args){
                let user = new User({
                    name: args.name,
                    age: args.age,
                    profession: args.profession
                });
                // console.log(user);
                // console.log("finished constructor user");
                // user.save();
                return user.save();
            }
        },
        
        updateUser: {
            type: UserType,
            args: {
                id: {type: new GraphQLNonNull(GraphQLID)},
                name: {type: GraphQLString},
                age: {type: GraphQLInt},
                profession: {type: GraphQLString}
            },
            resolve(parent,args){
                return User.findByIdAndUpdate(
                    args.id,
                    {
                        $set:{
                            name:args.name,
                            age:args.age,
                            profession:args.profession
                        }
                    },
                    {new: true} //send back the updated objectType
                );
            }
        },
        removeUser: {
            type: UserType,
            args: {
                id: {type: new GraphQLNonNull(GraphQLID)}
            },
            resolve(parent, args) {
                let removedUser = User.findByIdAndRemove(
                    args.id
                )//.exec();
                if(!removedUser){
                    throw new("Error");
                }
                return removedUser;
            }
        },
        
        //TODO: createPost mutation
        createPost: {
            type: PostType,
            args: {
                comment: {type: GraphQLString},
                userId: {type: new GraphQLNonNull(GraphQLID)}
            },
            resolve(parent, args){
                let post = new Post({
                    comment: args.comment,
                    time:Timestamp.now(),
                    userId: args.userId
                });
                return post.save();
            }
        },
        updatePost: {
            type: PostType,
            args: {
                id: {type: new GraphQLNonNull(GraphQLID)},
                comment: {type: GraphQLString},
                // userId: {type: GraphQLID}
            },
            resolve(parent,args){
                return Post.findByIdAndUpdate(
                    args.id,
                    {
                        $set:{
                            comment:args.comment,
                            time:Timestamp.now(),
                        }
                    },
                    {new:true}
                );
            }
        },
        // removePost: {
        //     type: PostType,
        //     args: {
        //         id: {type: new GraphQLNonNull(GraphQLID)}
        //     },
        //     resolve(parent, args) {
        //         let removedPost = Post.findByIdAndRemove(
        //             args.id
        //         ).exec();
        //         if(!removedPost){
        //             throw new("Error");
        //         }
        //         return removedPost;
        //     }
        // },
        
        //TODO: createHobby mutation
        createHobby: {
            type: HobbyType,
            args: {
                title: {type: GraphQLString},
                description: {type: GraphQLString},
                userId: {type: new GraphQLNonNull(GraphQLID)}
            },
            resolve(parent, args){
                let hobby = new Hobby({
                    title: args.title,
                    description: args.description,
                    userId: args.userId
                });
                return hobby.save();
            }
        },
        updateHobby: {
            type: HobbyType,
            args: {
                id: {type: new GraphQLNonNull(GraphQLID)},
                title: {type: GraphQLString},
                description: {type: GraphQLString},
                // userId: {type: GraphQLID}
            },
            resolve(parent,args){
                return Hobby.findByIdAndUpdate(
                    args.id,
                    {
                        $set:{
                            title:args.title,
                            description:args.description
                        },
                    },
                    {new: true}
                );
            }
        },
        // removeHobby: {
        //     type: HobbyType,
        //     args: {
        //         id: {type: new GraphQLNonNull(GraphQLID)}
        //     },
        //     resolve(parent, args) {
        //         let removedHobby = Hobby.findByIdAndRemove(
        //             args.id
        //         ).exec();
        //         if(!removedHobby){
        //             throw new("Error");
        //         }
        //         return removedHobby;
        //     }
        // },
    }
});

module.exports = new GraphQLSchema({
    query: RootQuery,
    mutation: Mutation
})

