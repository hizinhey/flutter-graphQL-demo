import 'package:flutter/material.dart';
import 'package:flutter_graphql_demo/todoModel.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

ValueNotifier<GraphQLClient> client;

String query = """{
    getTodos {
        id
        body
    }
}""";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final HttpLink httpLink = HttpLink(
    uri: "http://192.168.1.10:9000/graphql",
  );

  final AuthLink authLink = AuthLink(
    getToken: () async => 'Bearer <YOUR_PERSONAL_ACCESS_TOKEN>',
    // OR
    // getToken: () => 'Bearer <YOUR_PERSONAL_ACCESS_TOKEN>',
  );

  final Link link = authLink.concat(httpLink);
  client = ValueNotifier(
    GraphQLClient(
      cache: InMemoryCache(),
      link: link,
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  _handleAdd(String body) {}

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: MaterialApp(
          title: 'Flutter Demo',
          home: Scaffold(
            appBar: AppBar(),
            body: Home(),
          )),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

String delete = """
          mutation deleteTodo(\$todoId: ID!){
            deleteTodo(todoId: \$todoId) {
                
            }
        }
        """;

String add = """
          mutation createTodo(\$body: String!){
            createTodo(body: \$body) {
                body
            }
        }
        """;

_buildItem(String todoId, String body) {
  return Container(
    child: Row(
      children: [
        Mutation(
          options: MutationOptions(
            documentNode:
                gql(delete), // this is the mutation string you just created
            // you can update the cache based on results
            update: (Cache cache, QueryResult result) {
              return cache;
            },
            // or do something with the result.data on completion
            onCompleted: (dynamic resultData) {
              print(resultData);
            },
          ),
          builder: (
            RunMutation runMutation,
            QueryResult result,
          ) {
            return FlatButton(
              onPressed: () => runMutation({
                'todoId': todoId,
              }),
              child: Icon(Icons.remove_circle),
            );
          },
        ),
        Text(body)
      ],
    ),
  );
}

class _HomeState extends State<Home> {
  String textField;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                this.textField = value;
              });
            },
          ),
          Mutation(
            options: MutationOptions(
              documentNode:
                  gql(add), // this is the mutation string you just created
              // you can update the cache based on results
              update: (Cache cache, QueryResult result) {
                return cache;
              },
              // or do something with the result.data on completion
              onCompleted: (dynamic resultData) {
                print(resultData);
              },
            ),
            builder: (
              RunMutation runMutation,
              QueryResult result,
            ) {
              return FlatButton(
                onPressed: () => runMutation({
                  'body': textField,
                }),
                child: Text("ADD"),
              );
            },
          ),
          Query(
            options: QueryOptions(
              documentNode:
                  gql(query), // this is the query string you just created
              variables: {},
              pollInterval: 10,
            ),
            // Just like in apollo refetch() could be used to manually trigger a refetch
            // while fetchMore() can be used for pagination purpose
            builder: (QueryResult result,
                {VoidCallback refetch, FetchMore fetchMore}) {
              if (result.hasException) {
                return Text(result.exception.toString());
              }

              if (result.loading) {
                return Text('Loading');
              }

              // it can be either Map or List

              List repositories = result.data['getTodos'];
              return Container(
                  height: 300,
                  child: ListView.builder(
                      itemCount: repositories.length,
                      itemBuilder: (context, index) {
                        final repository = repositories[index];
                        return _buildItem(repository['id'], repository['body']);
                      }));
            },
          )
        ],
      ),
    );
  }
}
