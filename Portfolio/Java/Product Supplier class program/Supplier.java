public class Supplier {
	private String name;
	private String phone;
	
	public Supplier(String name, String phone) throws IllegalArgumentException {
		super();
		this.name = name;
		boolean foundMatch = phone.matches("[0]([0-9]{6,10})");
	    
	    if (!foundMatch) {
			throw new IllegalArgumentException("Invalid phone number.");
		}
		
		this.phone = phone;

	}

	public String getName() {
		return this.name;
	}

	public String getPhone() {
		return this.phone;
	}
	
}
