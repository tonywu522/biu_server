class Partner < ActiveRecord::Base
    belongs_to :user
    has_and_belongs_to_many :styles, join_table: "partners_styles", class_name: "Style", foreign_key: "partner_id", association_foreign_key: "style_id", dependent: :destroy
    has_and_belongs_to_many :zodiacs, join_table: "partners_zodiacs", class_name: "Zodiac", foreign_key: "partner_id", association_foreign_key: "zodiac_id", dependent: :destroy
    has_and_belongs_to_many :sexualities, join_table: "partners_sexualities", class_name: "Sexuality", foreign_key: "partner_id", association_foreign_key: "sexuality_id", dependent: :destroy
end
