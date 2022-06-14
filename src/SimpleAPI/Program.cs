using Microsoft.AspNetCore.Mvc;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

string BINDING_OPERATION = "create";

app.MapGet("/", ()=> {
    return "Container Apps can do Revisions!";
});

app.Run();
