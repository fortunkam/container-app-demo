using Dapr.Client;
using Microsoft.AspNetCore.Mvc;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

string BINDING_OPERATION = "create";

app.MapPost("/readqueue", async ([FromBody]int orderId)=> {
    Console.WriteLine("Input Binding 1: Received Message: " + orderId);

    string BINDING_NAME = "writequeue";

    using var client = new DaprClientBuilder().Build();
    await client.InvokeBindingAsync(BINDING_NAME, BINDING_OPERATION, $"New Order Received: {orderId}");

    Thread.Sleep(2000);
    return "CID" + orderId;
});

app.Run();
