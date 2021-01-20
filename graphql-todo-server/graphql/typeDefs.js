const { gql } = require("apollo-server");

module.exports = gql`
  type Todo {
    id: ID!
    body: String!
    created: String!
  }

  type Query {
    getTodos: [Todo]!
  }

  type Mutation {
    createTodo(body: String!): Todo!
    deleteTodo(todoId: ID!): String!
   }
`;