module Main exposing (..)

import Browser exposing (Document)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import Http
import Json.Decode as D
import Json.Encode as E

main =
  Browser.document
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

type State
  = Init
  | Failure String
  | Request String
  | Success String

type alias Model =
  { slug : String
  , token : String
  , state : State
  }

query : String
query = String.replace "\n" "" """
query TournamentQuery($slug: String, $numPlayers: Int!) {
  tournament(slug: $slug) {
    events {
      standings(query: { page: 1, perPage: $numPlayers }) {
        nodes {
          standing
          entrant {
            name
            participants {
              user {
                slug
                authorizations {
                  externalId
                  externalUsername
                  type
                }
              }
            }
          }
        }
      }
    }
  }
}
"""

graphql : String -> E.Value
graphql slug
  = E.object
    [ ("query", E.string query)
    , ("variables", E.object
      [ ("slug", E.string slug)
      , ("numPlayers", E.int 8)
      ])
    ]

request : String -> String -> Cmd Msg
request slug token = Http.request
      { method = "POST"
      , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
      , url = "https://api.smash.gg/gql/alpha"
      , body = Http.stringBody "application/json" (E.encode 0 (graphql slug))
      , expect = Http.expectString APIResponse
      , timeout = Nothing
      , tracker = Nothing
      }

init : () -> (Model, Cmd Msg)
init _ = ({ slug = "", token = "", state = Init }, Cmd.none)

type Msg
  = APIResponse (Result Http.Error String)
  | Slug String
  | Token String
  | Fetch

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Fetch -> ({ model | state = Request model.slug}, request model.slug model.token)
    Token str ->
      ({ model | token = str}, Cmd.none)
    Slug str ->
      ({ model | slug = str}, Cmd.none)
    APIResponse result ->
      case result of
        Ok data ->
          ({ model | state = Success data}, Cmd.none)

        Err _ ->
          ({ model | state = Failure "failed"}, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

type alias SocialConnection =
  { id : Maybe String
  , name : Maybe String
  , socialType : String
  }

-- {"externalId":null,"externalUsername":"djanatyn","type":"TWITTER"}
socialDecoder : D.Decoder SocialConnection
socialDecoder =
  D.map3 SocialConnection
    (D.maybe (D.field "externalId" D.string))
    (D.maybe (D.field "externalUsername" D.string))
    (D.field "type" D.string)

-- {"user":{"authorizations":[...]}}
participantDecoder : D.Decoder (List SocialConnection)
participantDecoder =
  (D.at ["user", "authorizations"] (D.list socialDecoder))

type alias Entrant =
  { name : String
  , connections : List (List SocialConnection)
  }

-- {"name":"...","participants":[{"user":{"authorizations":[...]}}]}
entrantDecoder : D.Decoder Entrant
entrantDecoder =
  D.map2 Entrant
    (D.at ["entrant", "name"] D.string)
    (D.at ["entrant", "participants"] (D.list participantDecoder))


-- [{"standings":{"nodes":[...]}}]
eventDecoder : D.Decoder (List Entrant)
eventDecoder = D.at ["standings", "nodes"] (D.list entrantDecoder)

-- {"data":{"tournament":{"events":[{"standings":{"nodes":[...]}}]}}}
responseDecoder : D.Decoder (List (List Entrant))
responseDecoder = (D.at ["data", "tournament", "events"] (D.list eventDecoder))

form : Model -> List (Html Msg)
form model
  = [ div [ class "container" ]
      [ text "slug"
      , input [ type_ "text", placeholder "waddle-wednesday", value model.slug, onInput Slug] []
      , text "token"
      , input [ type_ "password"
              , placeholder "09040aea5a6d4c7a9aae371e47fe142d"
              , value model.token
              , onInput Token
              ] []
      ]
      , div [ class "submit" ] [ input [ type_ "button", value "go!", onClick Fetch] [] ]
    ]

doc : Model -> List (Html Msg)
doc model
  = [ div [ class "wrapper"]
      ( [ text "smash.gg social finder (get twitter handles)"]
        ++ form model
        ++ [ text "author: DJAN (djanatyn@gmail.com) | https://github.com/djanatyn" ]
      )
    ]

view : Model -> Document Msg
view model =
  case model.state of
    Failure _ ->
      {title = "failed", body = doc model ++ [text "failed"]}

    Init ->
      { title = "smashgg twitter finder"
      , body = doc model
      }

    Request slug ->
      { title = "smashgg twitter finder"
      , body = doc model ++ [ text "fetching" ]
      }

    Success data ->
      {title = "success", body = doc model ++
           [case D.decodeString responseDecoder data of
                Ok _ -> text "successful decode"
                Err error -> text (D.errorToString error)
           ]}
