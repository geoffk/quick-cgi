$mail_mock_delivered = 0

class Mail::Message

  def deliver!
    $mail_mock_delivered += 1
  end

  def self.delivered
    $mail_mock_delivered
  end
end
