const { model, Schema } = require("mongoose");

const todoSchema = new Schema({
  body: String,
  created: String
});

module.exports = model("Todo", todoSchema);