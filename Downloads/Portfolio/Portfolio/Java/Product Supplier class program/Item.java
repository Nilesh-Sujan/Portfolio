import java.util.ArrayList;
import java.util.List;

public class Item implements IItem {
	/** Define a list of ingredients. */
	
	private List<Ingredient> ingredients;
	
	/**
	   * Default constructor for item object and where ingredient list gets initialised.
	   * 
	   */

	public Item() {
		super();
		this.ingredients = new ArrayList<Ingredient>();
	}

	/**
	 * Method to add ingredient to the ingredients list if it doesn't exist in the list already and it isn't null.
	 * 
	 * @return void	
	 * 
	 */

	@Override
	public void addIngredient(Ingredient ingredient) {
		if (ingredient != null) {
			if (!this.ingredients.contains(ingredient)) {
				this.ingredients.add(ingredient);
			}
		}
	}

	/**
	 * Method to get the total weight of the ingredients in the list.
	 * 
	 * @return double	
	 * 
	 */
	
	@Override
	public double getTotalWeight() {
		double sum = 0;
		
		for (Ingredient ingredient : this.ingredients) {
			sum += ingredient.getCookedWeight();
		}
		
		return sum;
	}
	
	/**
	 * Method to get the total calories of the ingredients in the list.
	 * 
	 * @return double	
	 * 
	 */

	@Override
	public double getTotalCalories() {
		double sum = 0;
		
		for (Ingredient ingredient : this.ingredients) {
			sum += ingredient.getCalories();
		}
		
		return sum;
	}
	
	/**
	 * Method to get the total fat of the ingredients in the list if it is a vegetable.
	 * 
	 * @return double	
	 * 
	 * @param IngredientType
	 */

	@Override
	public double getTotalFat(IngredientType type) {
		double sum = 0;
		
		for (Ingredient ingredient : this.ingredients) {
			if (type == ingredient.getType()) {
				sum += ingredient.getFat();
			}
		}
		
		return sum;
	}
	
	/**
	 * Method to get the total sodium of the ingredients in the list if it is a vegetable.
	 * 
	 * @return double	
	 * 
	 * @param IngredientType
	 */

	@Override
	public double getTotalSodium(IngredientType type) {
		double sum = 0;
		
		for (Ingredient ingredient : this.ingredients) {
			if (type == ingredient.getType()) {
				sum += ingredient.getSodium();
			}
		}
		
		return sum;
	}

}
