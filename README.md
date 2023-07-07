# packaging-demo


### TO-DO:

- Prioritize the following list :)
- For giant app and hello app, if target is large, use Knative Service, else use Deployent + Service
- Move namespace config to child of app name key
- Update auto-generation of namespace resource condition to use namespace name rather than owner field
- Make a large and small metapackage repos (separate)
~~- Rename redis package to hello-redis~~

Icebox
- Parameterize script ?? maybe not ?


```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: hello-app
spec:
  template:
    spec:
      containers:
        - image: taplab.azurecr.io/packaging-demo/hello-app:1.2.3
          ports:
            - containerPort: 8080
          env:
            - name: HELLO_MSG
              value: "World"
            - name: REDIS
              value: "World"
```
