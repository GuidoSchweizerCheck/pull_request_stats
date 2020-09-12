PullRequestsQuery = GithubClient.parse <<-'GRAPHQL'
  query($repositoryOwner: String!, $repositoryName: String!, $after: String) {
    repository(owner: $repositoryOwner, name: $repositoryName) {
      pullRequests(orderBy: { field: UPDATED_AT, direction: DESC }, first: 100, after: $after) {
        pageInfo {
          endCursor
          hasNextPage
        }

        nodes {
          id: databaseId
          number
          title
          createdAt
          updatedAt

          author {
            login
            avatarUrl

            ... on User {
              id: databaseId
              createdAt
              updatedAt
            }
          }

          reviews(first: 100) {
            nodes {
              id: databaseId
              createdAt
              updatedAt

              author {
                login
                avatarUrl

                ... on User {
                  id: databaseId
                  createdAt
                  updatedAt
                }
              }
            }
          }
        }
      }
    }
  }
GRAPHQL
