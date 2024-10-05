from django.db import models

class Option(models.Model):
    underlying_price = models.FloatField()
    strike_price = models.FloatField()
    time_to_expiry = models.FloatField()  # in years
    volatility = models.FloatField()
    risk_free_rate = models.FloatField()

