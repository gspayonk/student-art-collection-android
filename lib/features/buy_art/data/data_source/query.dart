const String GET_ALL_ARTWORK_FOR_BUYER = r'''
query getAllArtwork{
  allArts{
    id
    school_id
    price
    sold
    title
    artist_name
    description
    date_posted
  images{
    id
    art_id
    image_url
  }
    category{
  id
  category
  }
}
}
    ''';