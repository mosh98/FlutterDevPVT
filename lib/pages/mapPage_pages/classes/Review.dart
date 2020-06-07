class Review {

    int _id;
    int _rating;
    String _comment;


    int get id => _id;
    int get rating => _rating;
    String get comment => _comment;



    Review({int id, int rating, String comment}) {
        this._id = id;
        this._rating = rating;
        this._comment = comment;
    }

    factory Review.fromJson(Map<String, dynamic> json) {
        return Review(
            id: json['id'],
            rating: json['rating'],
            comment: json['comment'],
        );
    }

    @override
    String toString() {
        return "$_id\t$_rating\t$_comment";
    }


}

