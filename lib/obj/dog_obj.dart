class DogObj{

  String message = "";
  String status = "";

  DogObj.fromMap(Map <String,dynamic>map){

    message = map['message'];
    status = map['status'];

}


}