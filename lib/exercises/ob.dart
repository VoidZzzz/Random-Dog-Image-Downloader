class Ob{

  String message='';
  String status='';

  Ob.fromMap(Map<String,dynamic>map){

    message=map['message'];
    status=map['status'];


}

}