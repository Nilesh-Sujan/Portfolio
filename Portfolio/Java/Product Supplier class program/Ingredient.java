public class Ingredient {
	private String name;
	private IngredientType type;
	private Supplier supplier;
	private double rawWeight;
	private double calories;
	private double fat;
	private double sodium;
	
	public Ingredient(String name, IngredientType type, Supplier supplier, double rawWeight, double calories, double fat, double sodium) {
		super();
		
		if (name == null || type == null || supplier == null || rawWeight <= 0  || calories <= 0  || fat <= 0 || sodium <= 0 ) {
			throw new IllegalArgumentException("Incorrect input values.");
		} else {
			this.name = name;
			this.type = type;
			this.supplier = supplier;
			this.rawWeight = rawWeight;
			this.calories = calories;
			this.fat = fat;
			this.sodium = sodium;
		}	
	}
	
	public double getCookedWeight() {
		return (0.8 * this.rawWeight);
	}

	public String getName() {
		return this.name;
	}

	public IngredientType getType() {
		return this.type;
	}

	public Supplier getSupplier() {
		return this.supplier;
	}

	public double getRawWeight() {
		return this.rawWeight;
	}

	public double getCalories() {
		return this.calories;
	}

	public double getFat() {
		return this.fat;
	}

	public double getSodium() {
		return this.sodium;
	}
	
}
