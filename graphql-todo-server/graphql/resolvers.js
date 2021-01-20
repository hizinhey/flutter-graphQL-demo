// we need a Todo model in our mutations to modify the data.
const Todo = require('../models/Todo');

module.exports = {
  Query: {
    // here is the getTodos, that we defined in our typeDefs.
    // simply, using the Todo model to fetch all the todos with async/await
    // and return the result.
    async getTodos() {
      try {
        const todos = await Todo.find({}).sort({ created: -1 });
        return todos;
      } catch (err) {
        throw new Error(err);
      }
    }
  },

  Mutation: {
      async createTodo(_, { body }) {
    // destructure the body from our args.
    // create a new Todo, save and return that todo
    // created is the date.
      try {
        const newTodo = new Todo({
          body,
          created: new Date().toISOString()
        });
        const todo = await newTodo.save();
        return todo;
      } catch (err) {
        throw new Error(err);
      }
    },

    async deleteTodo(_, { todoId }) {
      // Find the todo by its Id and delete it.
      try {
        const todo = await Todo.findById(todoId);
        if (todo) {
            await todo.delete();
            return 'Todo deleted!';
        } else {
            return 'Todo does not exist'
        }
      } catch (err) {
        throw new Error(err);
      }
    }
  }
};