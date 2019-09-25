module Application exposing (main)

import Browser
import Extensions


main : Program () Extensions.Model Extensions.Msg
main =
    Browser.application
        { init = \flags _ _ -> Extensions.init flags
        , update = Extensions.update
        , subscriptions = Extensions.subscriptions
        , view =
            \model ->
                { title = ""
                , body = [ Extensions.view model ]
                }
        , onUrlRequest = Extensions.onUrlRequest
        , onUrlChange = \_ -> Extensions.noop
        }
