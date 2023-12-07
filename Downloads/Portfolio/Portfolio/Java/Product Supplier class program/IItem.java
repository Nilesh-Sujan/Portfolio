public interface IItem {
	public abstract void addIngredient(Ingredient ingredient);
	public abstract double getTotalWeight();
	public abstract double getTotalCalories();
	public abstract double getTotalFat(IngredientType type);
	public abstract double getTotalSodium(IngredientType type);
}
