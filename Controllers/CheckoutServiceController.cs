using System.Collections.Generic;
using System.Threading.Tasks;
using System;
using Microsoft.AspNetCore.Mvc;
using Dapr.Client;

//code
namespace CheckoutService.controller
{
    [ApiController]
    public class CheckoutServiceController : Controller
    {
        
        
        [HttpPost("/inputbinding1")]
        public async Task<ActionResult<string>> processMessageSQ([FromBody] int orderId)
        {
            Console.WriteLine("Input Binding 1: Received Message: " + orderId);

            string BINDING_NAME = "outputbinding1";
		    string BINDING_OPERATION = "create";

            using var client = new DaprClientBuilder().Build();
            await client.InvokeBindingAsync(BINDING_NAME, BINDING_OPERATION, $"Input Binding 1 to Output Binding 1: {orderId}");

            return "CID" + orderId;
        }

        [HttpPost("/inputbinding2")]
        public async Task<ActionResult<string>> processMessageSB([FromBody] int orderId)
        {
            Console.WriteLine("Input Binding 2: Received Message: " + orderId);

            string BINDING_NAME = "outputbinding2";
		    string BINDING_OPERATION = "create";

            using var client = new DaprClientBuilder().Build();
            await client.InvokeBindingAsync(BINDING_NAME, BINDING_OPERATION, $"Input Binding 2 to Output Binding 2: {orderId}");

            return "CID" + orderId;
        }
    }
}