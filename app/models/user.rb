require 'openssl'

# Модель пользователя.
# Каждый экземпляр этого объекта — загруженная из БД инфа о конкретном юзере.

class User < ApplicationRecord
  # параметры работы модуля шифрования паролей
  ITERATIONS = 20000
  DIGEST = OpenSSL::Digest::SHA256.new

  # эта команда добавляет связь с моделью Question на уровне объектов
  # она же добавляет метод .questions к данному объекту

  has_many :questions

  # если не задан email и username, объект не будет сохранен в базу
  validates :email, :username, presence: true

  # если email и username не уникальны (уже такие есть в баже),
  # объект не будет сохранен в базу
  validates :email, :username, uniqueness: true
  #проверка адреса эл почты
  validates :email, format: {with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/}
  #юзернэйм максимум 40 знаков в формате (только латинские буквы, цифры, и знак _)
  validates :username, length: {maximum: 40}, format: {with: /\A[a-zA-Z0-9"_"]+\z/}

  before_validation :username_downcase

  def username_downcase
    if username =~ /[A-Z]/
      self.username = username.downcase
    else
      username
    end
  end

  # виртуальное поле, которое не сохраняется в базу
  # из него перед сохранение читается пароль, и сохраняется в базу уже
  # зашифрованная версия пароля в реальные поля password_salt и password_hash
  attr_accessor :password

  # Это поле нужно только при создании (create) нового юзера - регистрации.
  # При аутентификации (логине) - мы будем сравнивать уже зашифрованные поля
  validates_presence_of :password, on: :create

  # Требует совпадения значений полей password и password_confirmation
  # Понадобится при создании формы регистрации, чтобы снизить число ошибочно введенных паролей
  validates_confirmation_of :password

  # перед сохранением объекта в базу - создаем зашифрованный пароль, который будет хранится в БД
  before_save :encrypt_password

  # шифруем пароль, если он задан
  def encrypt_password
    if self.password.present?

      # создаем т. н. "соль" - рандомная строка усложняющая задачу хакерам
      self.password_salt = User.hash_to_string(OpenSSL::Random.random_bytes(16))

      # создаем хэш пароля — длинная уникальная строка, из которой невозможно восстановить
      # исходный пароль
      self.password_hash = User.hash_to_string(
          OpenSSL::PKCS5.pbkdf2_hmac(self.password, self.password_salt, ITERATIONS, DIGEST.length, DIGEST)
      )
    end
    # оба поля окажутся записанными в базу
  end


  # служебный метод, преобразующий бинарную строку в 16-ричный формат, для удобства хранения
  def self.hash_to_string(password_hash)
    password_hash.unpack('H*')[0]
  end

  # Основной метод для аутентификации юзера (логина)
  # Проверяет email и пароль, если пользователь с такой комбинацией есть в базе
  # возвращает этого пользователя.
  # Если нету — возвращает nil
  def self.authenticate(email, password)
    user = find_by(email: email) # сперва находим кандидата по email

    # ОБРАТИТЕ внимание: сравнивается password_hash, а оригинальный пароль так никогда
    # и не сохраняется нигде!
    if user.present? && user.password_hash == User.hash_to_string(OpenSSL::PKCS5.pbkdf2_hmac(password, user.password_salt, ITERATIONS, DIGEST.length, DIGEST))
      user
    else
      nil
    end
  end

end
