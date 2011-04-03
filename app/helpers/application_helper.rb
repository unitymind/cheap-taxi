require "yajl"
module ApplicationHelper
  def encode_to_json(data)
    Yajl::Encoder.encode(data)
  end
end
