module ApplicationHelper
  def user_avatar(user)
    if user.avatar_url.present?
      user.avatar_url
    else
      asset_path 'avatar.jpg'
    end
  end

  def fa_icon(icon_class)
    content_tag 'span', '', class: "fa fa-#{icon_class}"
  end

  def question_count(user, krokodil, krokodila, krokodilov)
    @number = @questions.length

    if (@number == nil || !@number.is_a?(Numeric))
      number = 0 # если первый параметр пустой или не число, то продолжаем как будто он нулевой
    end

    # условия для исключений
    if @number >= 11 && @number <= 14 || @number % 100 >= 11 && @number % 100 <= 14
      return krokodilov
    end

    ostatok = @number % 10 # склонение определяется последней цифрой в числе

    if (ostatok == 1) # для 1 - именительный падеж (Кто? Что?)
      return krokodil
    end

    if (ostatok >= 2 && ostatok <= 4) # для 2-4 - родительный падеж (Кого? Чего?)
      return krokodila
    end

    # 5-9 или ноль – родительный падеж и множественное число
    if (ostatok >= 5 && ostatok <= 9 || ostatok == 0)
      return krokodilov
    end

  end

end
