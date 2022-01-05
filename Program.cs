using Dapr.Client;
using Microsoft.AspNetCore.Mvc;

var builder = WebApplication.CreateBuilder(args);

var app = builder.Build();

string BINDING_OPERATION = "create";

app.MapPost("/inputbinding1", async ([FromBody]int orderId)=> {
    Console.WriteLine("Input Binding 1: Received Message: " + orderId);

    string BINDING_NAME = "outputbinding1";

    using var client = new DaprClientBuilder().Build();
    await client.InvokeBindingAsync(BINDING_NAME, BINDING_OPERATION, $"Input Binding 1 to Output Binding 1: {orderId}");

    Thread.Sleep(2000);
    return "CID" + orderId;
});

app.MapPost("/inputbinding2", async ([FromBody]int orderId)=> {
    Console.WriteLine("Input Binding 2: Received Message: " + orderId);

    string BINDING_NAME = "outputbinding2";

    using var client = new DaprClientBuilder().Build();
    await client.InvokeBindingAsync(BINDING_NAME, BINDING_OPERATION, $"Input Binding 2 to Output Binding 2: {orderId}");

    return "CID" + orderId;
});

app.MapGet("/", ()=> {
    return "Hello World";
});

app.MapGet("/getSecret", async ()=> {
    string SECRET_STORE_NAME = "dapr-secrets";
    string K8S_SECRET_NAME = "dapr-secrets";
    using var client = new DaprClientBuilder().Build();
    var secret = await client.GetSecretAsync(SECRET_STORE_NAME, K8S_SECRET_NAME);
    return secret["secret-type"];
});


app.Run();
