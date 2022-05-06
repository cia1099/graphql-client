// const mongoose = require("mongoose");
// const MSchema = mongoose.Schema;

// const UserSchema = new MSchema({
//     name: String,
//     age: Number,
//     profession: String
// });
// module.exports = mongoose.model("User", UserSchema);
const { initializeApp, applicationDefault, cert } = require('firebase-admin/app');
const { getFirestore, Timestamp, FieldValue } = require('firebase-admin/firestore');
const serviceAccount = require('../config/flutter-web-128a1-firebase-adminsdk.json');
initializeApp({
  credential: cert(serviceAccount)
});
// initializeApp();
const db = getFirestore();

class User {
    constructor(obj){
        this.name = obj.name;
        this.age = obj.age;
        this.profession = obj.profession;
    }
    async save(){
        var newId;
        const docRef = await db.collection("QUser").add({
            name:this.name,
            age:this.age,
            profession:this.profession
        })
        // .then(docRef => {
        //     // db.collection("User").doc(res.id).update({id:res.id});
        //     docRef.update({id:res.id});
        //     newId = res.id;
        // }).get();
        await docRef.update({id:docRef.id});
        const doc = await docRef.get();

        return doc.data();//User.findById(newId);
    }
    
    static async findById(id){
        const doc = await db.collection("QUser").doc(id).get();
        if (!doc.exists) {
            throw new('No such document!');
        }
        return doc.data();
    }

    static async findByIdAndUpdate(id, Mobj, opt){
        const docRef = await db.collection("QUser").doc(id);
        await docRef.update(JSON.parse(JSON.stringify(Mobj.$set)));
        const doc = await docRef.get();

        return doc.data();
    }

    static async findByIdAndRemove(id){
        db.collection("QPost").where("userId",'==',id).get().then(docs =>{
            if(!docs.empty){
                const batch = db.batch();
                docs.forEach(doc => batch.delete(doc.ref));
                batch.commit();
            }
        });
        db.collection("QHobby").where("userId",'==',id).get().then(docs =>{
            if(!docs.empty){
                const batch = db.batch();
                docs.forEach(doc => batch.delete(doc.ref));
                batch.commit();
            }
        });
        return db.collection("QUser").doc(id).delete();
    }

    static async getAll(){
        var users = [];
        const colRef = await db.collection("QUser").get();
        colRef.forEach(doc => {
            users.push(doc.data());
        });
        return users;
    }
}

module.exports = User, db;