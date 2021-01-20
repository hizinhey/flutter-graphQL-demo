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
  HttpLink httpLink = HttpLink(
    uri: 'http://localhost:9000/graphql',
  );

  AuthLink authLink = AuthLink(
    getToken: () async => 'Bearer <YOUR_PERSONAL_ACCESS_TOKEN>',
  );

  Link link = authLink.concat(httpLink);

  client = ValueNotifier(
    GraphQLClient(
      cache: InMemoryCache(),
      link: link,
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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

_buildItem(String id, String body, String created) {
  return Container(
      child: Row(
    children: [
      IconButton(
        icon: Icon(Icons.remove_circle_outline),
        onPressed: () {},
      ),
      Text(body)
    ],
  ));
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
          FlatButton(
            child: Text("Add"),
            onPressed: () {},
          ),
          Query(
            options: QueryOptions(
              documentNode:
                  gql(query), // this is the query string you just created
              pollInterval: 10,
            ),
            // Just like in apollo refetch() could be used to manually trigger a refetch
            // while fetchMore() can be used for pagination purpose
            builder: (QueryResult result,
                {VoidCallback refetch, FetchMore fetchMore}) {
              if (result.hasException) {
                print(result.exception.toString());
                return Text(result.exception.toString());
              }

              if (result.loading) {
                return Text('Loading');
              }

              // it can be either Map or List
              List repositories = result.data['getTodos'];

              return ListView.builder(
                  itemCount: repositories.length,
                  itemBuilder: (context, index) {
                    final repository = repositories[index];

                    return _buildItem(repository['id'], repository["body"],
                        repository["created"]);
                  });
            },
          )
        ],
      ),
    );
  }
}
