public class Factory {

	/** The name of the factory. */
	private String name = null;

	/** The factory's address: number. */
	private int number = 0;

	/** The factory's address: street. */
	private String street = null;

	/** The factory's address: city. */
	private String city = null;

	/** The factory's address: county. */
	private String county = null;

	/** The factory's address: post code. */
	private String postcode = null;

	/** The factory's address: country. */
	private String country = null;

	/**
	 * Constructor allowing the name and address of the factory to be specified.
	 * 
	 * @param name     the name of the factory.
	 * @param number   the factory's address: number.
	 * @param street   the factory's address: street.
	 * @param city     the factory's address: city.
	 * @param county   the factory's address: county.
	 * @param postcode the factory's address: postcode.
	 * @param country  the factory's address: country.
	 */
	public Factory(String name, int number, String street, String city, String county, String postcode,
			String country) {
		super();
		if (name == null || number <= 0 || street == null || city == null || county == null || postcode == null
				|| country == null) {
			throw new IllegalArgumentException("Wrong input format");
		} else {
			this.name = name;
			this.number = number;
			this.street = street;
			this.city = city;
			this.county = county;
			this.postcode = postcode;
			this.country = country;
		}
	}

	/**
	 * @return the factory's name and address in a pretty format.
	 */
	public String getAddress() {
		StringBuffer buffer = new StringBuffer();

		buffer.append(this.name);
		buffer.append("\n");

		buffer.append(this.number);
		buffer.append(" ");
		buffer.append(this.street);
		buffer.append("\n");

		buffer.append(this.city);
		buffer.append("\n");

		buffer.append(this.county);
		buffer.append("\n");

		buffer.append(this.postcode);
		buffer.append("\n");

		buffer.append(this.country);
		buffer.append("\n");

		return buffer.toString();
	}

	/**
	 * @return the factory's city
	 */
	public String getCity() {
		return this.city;
	}

	/**
	 * @return the factory's country
	 */
	public String getCountry() {
		return this.country;
	}

	/**
	 * @return the factory's county
	 */
	public String getCounty() {
		return this.county;
	}

	/**
	 * @return the factory's name
	 */
	public String getName() {
		return this.name;
	}

	/**
	 * @return the factory's number
	 */
	public int getNumber() {
		return this.number;
	}

	/**
	 * @return the factory's postcode
	 */
	public String getPostcode() {
		return this.postcode;
	}

	/**
	 * @return the factory's street
	 */
	public String getStreet() {
		return this.street;
	}
}
