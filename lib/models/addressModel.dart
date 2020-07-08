class AddressModel {
  final int id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String address;
  final String lat;
  final String long;

  AddressModel(
      {this.firstName,
      this.lastName,
      this.phone,
      this.address,
      this.email,
      this.lat,
      this.long,
      this.id});
}
