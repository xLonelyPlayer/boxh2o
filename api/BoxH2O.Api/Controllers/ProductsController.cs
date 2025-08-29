using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BoxH2O.Api.Data;
using BoxH2O.Api.Models;

namespace BoxH2O.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly ILogger<ProductsController> _logger;

    public ProductsController(AppDbContext context, ILogger<ProductsController> logger)
    {
        _context = context;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<Product>>> GetProducts()
    {
        _logger.LogInformation("Retrieving all products");
        return await _context.Products.ToListAsync();
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<Product>> GetProduct(int id)
    {
        _logger.LogInformation("Retrieving product with id {ProductId}", id);
        
        var product = await _context.Products.FindAsync(id);

        if (product == null)
        {
            _logger.LogWarning("Product with id {ProductId} not found", id);
            return NotFound();
        }

        return product;
    }

    [HttpPost]
    public async Task<ActionResult<Product>> CreateProduct(Product product)
    {
        _logger.LogInformation("Creating new product");
        
        _context.Products.Add(product);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetProduct), new { id = product.Id }, product);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateProduct(int id, Product product)
    {
        if (id != product.Id)
        {
            return BadRequest();
        }

        _logger.LogInformation("Updating product with id {ProductId}", id);
        
        _context.Entry(product).State = EntityState.Modified;
        product.UpdatedAt = DateTime.UtcNow;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!await ProductExists(id))
            {
                _logger.LogWarning("Product with id {ProductId} not found during update", id);
                return NotFound();
            }
            throw;
        }

        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteProduct(int id)
    {
        _logger.LogInformation("Deleting product with id {ProductId}", id);
        
        var product = await _context.Products.FindAsync(id);
        if (product == null)
        {
            _logger.LogWarning("Product with id {ProductId} not found during deletion", id);
            return NotFound();
        }

        _context.Products.Remove(product);
        await _context.SaveChangesAsync();

        return NoContent();
    }

    private async Task<bool> ProductExists(int id)
    {
        return await _context.Products.AnyAsync(e => e.Id == id);
    }
}