class Review {

    int _id;
    int _rating;
    String _comment;


    int getID() { return _id; }
    int getRating() { return _rating; }
    String getComment() { return _comment; }



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

