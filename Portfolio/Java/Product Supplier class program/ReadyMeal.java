import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class ReadyMeal {
	private String name;
	private ProductType type;
	private Factory factory;
	private Date productionDate = null;
	private List<IItem> items;
	
	public ReadyMeal(String name, ProductType type, Factory factory) {
		super();
		
		if (name == null || type == null || factory == null) {
			throw new IllegalArgumentException("Incorrect input values.");
		} else {
			this.name = name;
			this.type = type;
			this.factory = factory;
			this.productionDate = new Date();
			this.items = new ArrayList<IItem>();
		}
	}
	
	public void addItem(IItem item) {
		if (item != null) {
			if (!this.items.contains(item)) {
				this.items.add(item);
				this.productionDate = new Date();
			}
		}
	}
	
	public String printContent() {
		StringBuffer text = new StringBuffer();
		
		for (IItem Item : this.items) {
			String grammar = this.type.toString().toLowerCase();
			text.append(grammar.substring(0, 1).toUpperCase() + grammar.substring(1));
			text.append(" ");
			text.append(this.name);
			text.append(" ");
			text.append("Ready Meal");
			text.append(" ");
			text.append(Item.getTotalWeight());
			text.append(" g");
			text.append("\n");
			text.append("\n");
			
			text.append("Contents");
			text.append("\n");
			text.append("Calories: ");
			text.append(Item.getTotalCalories());
			text.append("kcal");
			text.append("\n");
			text.append("Meat (fat): ");
			text.append(Item.getTotalFat(IngredientType.MEAT));
			text.append("g");
			text.append("\n");
			text.append("Vegetable (sodium): ");
			text.append(Item.getTotalSodium(IngredientType.VEGETABLE));
			text.append("g");
			text.append("\n");
			text.append("\n");
			
			text.append(this.factory.getAddress());
		}
		return text.toString();
	}

	public String getName() {
		return this.name;
	}

	public ProductType getType() {
		return this.type;
	}

	public Factory getFactory() {
		return this.factory;
	}
}
