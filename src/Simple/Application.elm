module Simple.Application exposing (main)

import Browser
import Dict
import Simple.Common exposing (Model, Msg, init, noop, onUrlRequest, subscriptions, update, view)


main : Program () Model Msg
main =
    Browser.application
        { init = \flags _ _ -> init flags
        , update = update
        , subscriptions = subscriptions
        , view =
            \model ->
                { title = String.fromInt (Dict.size model)
                , body = view model
                }
        , onUrlRequest = onUrlRequest
        , onUrlChange = \_ -> noop
        }
