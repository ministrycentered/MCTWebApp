### MCTWebApp

Create a web wraper app.

### JavaScript Support

`window.webkit.messageHandlers.OBSERVER_NAME.postMessage(obj)`

##### Message handlers added by framework

- `log` Logs a message to the iOS console.

    Calling this with the message `Testing Logging` will output `2014-11-25 11:19:14.983 MyWebApp[586:4035547] current.open.domain.com - "Testing Logging"` to the iOS console.

- `openExternal` Checks if the link can be opened by the system.  Expects an Object

    ```
window.webkit.messageHandlers.openExternal.postMessage({url: 'http://google.com', callback: 'MyOpenURLCallbackFunction'})
    ```

    In that example `MyOpenURLCallbackFunction` will take one parameter that will be a JSON string `{"url": "http://google.com", "status": "true"}`.  url is the URL you tried to open.  And status is a true|false string for success of opening the URL

- `open`  Opens the passed URL in the current webView.

- `goForward`

- `goBack`

- `loadRoot`

- `canGoForward` Takes an Object with a `callback`

- `canGoBack` Takes an Object with a `callback`

- `showNavigation`

- `hideNavigation`

- `openFile` Downloads and opens the file.  Takes Object with `url`, and an optional `name`

- `endEditing`

- `showNavigation`

- `hideNavigation`

- `openInModal` Same as `open` but opens in a modal web view controller.









